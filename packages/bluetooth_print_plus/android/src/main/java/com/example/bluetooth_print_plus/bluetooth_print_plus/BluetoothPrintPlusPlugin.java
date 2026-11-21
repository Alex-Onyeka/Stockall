package com.example.bluetooth_print_plus.bluetooth_print_plus;

import static android.bluetooth.BluetoothDevice.DEVICE_TYPE_LE;

import static androidx.core.app.ActivityCompat.startActivityForResult;

import android.Manifest;
import android.app.Activity;
import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.RequiresApi;

import com.example.bluetooth_print_plus.bluetooth_print_plus.payload.BPPState;
import com.example.bluetooth_print_plus.bluetooth_print_plus.payload.BluetoothParameter;
import com.example.bluetooth_print_plus.bluetooth_print_plus.payload.Printer;
import com.example.bluetooth_print_plus.bluetooth_print_plus.payload.ThreadPoolManager;
import com.gprinter.bean.PrinterDevices;
import com.gprinter.io.PortManager;
import com.gprinter.utils.CallbackListener;
import com.gprinter.utils.Command;
import com.gprinter.utils.LogUtils;
import com.gprinter.utils.ConnMethod;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.*;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;
import pub.devrel.easypermissions.EasyPermissions;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/**
 * BluetoothPrintPlusPlugin
 *
 * @author amoLink
 */
public class BluetoothPrintPlusPlugin
        implements FlutterPlugin, ActivityAware, MethodCallHandler, RequestPermissionsResultListener {
  private static final String TAG = "BluetoothPrintPlusPlugin";
  private static final int REQUEST_LOCATION_PERMISSIONS = 1452;
  private final Object initializationLock = new Object();
  private Context context;
  private Activity activity;
  private Result pendingResult;
  public PortManager portManager = null;
  private BluetoothAdapter mBluetoothAdapter;

  private FlutterPluginBinding pluginBinding;
  private ActivityPluginBinding activityBinding;
  private MethodChannel channel;
  private EventSink sink;
  private MethodChannel tscChannel;
  private MethodChannel cpclChannel;
  private MethodChannel escChannel;
  private EventChannel stateChannel;
  private final TscCommandPlugin tscCommandPlugin = new TscCommandPlugin();
  private final CpclCommandPlugin cpclCommandPlugin = new CpclCommandPlugin();
  private final EscCommandPlugin escCommandPlugin = new EscCommandPlugin();

  public BluetoothPrintPlusPlugin() {}

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    pluginBinding = binding;
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    pluginBinding = null;
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    activityBinding = binding;
    setup(
            pluginBinding.getBinaryMessenger(),
            (Application) pluginBinding.getApplicationContext(),
            activityBinding.getActivity(),
            activityBinding
    );
  }

  @Override
  public void onDetachedFromActivity() {
    tearDown();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  private void setup(
          final BinaryMessenger messenger,
          final Application application,
          final Activity activity,
          final ActivityPluginBinding activityBinding
  ) {
    synchronized (initializationLock) {
      LogUtils.i(TAG, "setup");
      this.activity = activity;
      this.context = application;
      channel = new MethodChannel(messenger, "bluetooth_print_plus/methods");
      channel.setMethodCallHandler(this);
      // tsc Channel
      tscChannel = new MethodChannel(messenger, "bluetooth_print_plus_tsc");
      tscCommandPlugin.setUpChannel(tscChannel);
      // cpcl Channel
      cpclChannel = new MethodChannel(messenger, "bluetooth_print_plus_cpcl");
      cpclCommandPlugin.setUpChannel(cpclChannel);
      // esc Channel
      escChannel = new MethodChannel(messenger, "bluetooth_print_plus_esc");
      escCommandPlugin.setUpChannel(escChannel);
      // state Channel
      stateChannel = new EventChannel(messenger, "bluetooth_print_plus/state");
      stateChannel.setStreamHandler(stateHandler);
      mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

      activityBinding.addRequestPermissionsResultListener(this);
      initBroadcast();
    }
  }

  private void tearDown() {
    LogUtils.i(TAG, "teardown");
    try {
      if (context != null) {
        context.unregisterReceiver(mFindBlueToothReceiver);
      }
    } catch (Exception ignored) {
    }
    context = null;
    activityBinding.removeRequestPermissionsResultListener(this);
    activityBinding = null;
    channel.setMethodCallHandler(null);
    channel = null;
    stateChannel.setStreamHandler(null);
    stateChannel = null;
    mBluetoothAdapter = null;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (mBluetoothAdapter == null && !"isAvailable".equals(call.method)) {
      result.error("bluetooth_unavailable", "the device does not have bluetooth", null);
      return;
    }
    switch (call.method) {
      case "state":
        state(result);
        break;
      case "startScan":
        startScan(result);
        break;
      case "stopScan":
        stopScan();
        result.success(null);
        break;
      case "connect":
        Map<String, Object> args = call.arguments();
        assert args != null;
        final String address = (String) args.get("address");
        stopScan();
        connect(address);
        result.success(null);
        break;
      case "disconnect":
        Printer.close();
        result.success(null);
        break;
      case "write":
        byte[] bytes = call.argument("data");
        try {
          result.success(write(bytes));
        } catch (IOException e) {
          result.error("write_failed", e.getMessage(), null);
        }
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void initBroadcast() {
    try {
      IntentFilter filter = new IntentFilter();
      filter.addAction(BluetoothDevice.ACTION_FOUND);
      filter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        context.registerReceiver(mFindBlueToothReceiver, filter, Context.RECEIVER_EXPORTED);
      } else {
        context.registerReceiver(mFindBlueToothReceiver, filter);
      }
    } catch (Exception ignored) {

    }
  }

  private final BroadcastReceiver mFindBlueToothReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      try {
        String action = intent.getAction();
        if (BluetoothDevice.ACTION_FOUND.equals(action)) {
          BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
          if (device == null || device.getName() == null) return;
          if (device.getType() == DEVICE_TYPE_LE) return;
          BluetoothParameter parameter = new BluetoothParameter();
          int rssi = intent.getExtras() != null
              ? intent.getExtras().getShort(BluetoothDevice.EXTRA_RSSI)
              : 0;
          parameter.setBluetoothName(device.getName());
          parameter.setBluetoothMac(device.getAddress());
          parameter.setBluetoothStrength(rssi + "");
          LogUtils.i(TAG, "\nBlueToothName: " + device.getName() + "\nMacAddress: " + device.getAddress() + "\nrssi: " + rssi);
          invokeMethodUIThread(device);
        }
      } catch (Exception ignored) {
      }
    }
  };

  private void state(Result result) {
    try {
      switch (mBluetoothAdapter.getState()) {
        case BluetoothAdapter.STATE_OFF:
          result.success(BPPState.BlueOff.getValue());
          break;
        case BluetoothAdapter.STATE_ON:
          result.success(BPPState.BlueOn.getValue());
          break;
        default:
          break;
      }
    } catch (SecurityException e) {
      result.error("invalid_argument", "argument 'address' not found", null);
    }
  }

  private void startScan(Result result) {
    LogUtils.i(TAG, "start scan...");
    try {
      String[] perms;
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        perms = new String[] {
          Manifest.permission.BLUETOOTH_CONNECT,
          Manifest.permission.BLUETOOTH_SCAN,
        };
      } else {
        perms = new String[] {
          Manifest.permission.BLUETOOTH,
          Manifest.permission.BLUETOOTH_ADMIN,
          Manifest.permission.ACCESS_FINE_LOCATION,
        };
      }
      if (EasyPermissions.hasPermissions(this.context, perms)) {
        // Already have permission, do the thing
        startScan();
      } else if (this.activity != null) {
        // Do not have permissions, request them now
        EasyPermissions.requestPermissions(
                this.activity,
                "Bluetooth permission is required to scan printers",
                REQUEST_LOCATION_PERMISSIONS,
                perms);
      }
      result.success(null);
    } catch (Exception e) {
      result.error("startScan", e.getMessage(), e);
    }
  }

  private void invokeMethodUIThread(BluetoothDevice device) {
    final Map<String, Object> ret = new HashMap<>();
    ret.put("address", device.getAddress());
    ret.put("name", device.getName());
    ret.put("type", device.getType());
    new Handler(Looper.getMainLooper()).post(() -> {
      if (channel != null && !ret.isEmpty()) {
        channel.invokeMethod("ScanResult", ret);
      } else {
        LogUtils.w(TAG, "invokeMethodUIThread: tried to call method on closed channel: " + "ScanResult");
      }
    });
  }

  private void startScan() throws IllegalStateException {
    if (mBluetoothAdapter == null) return;
    try {
      mBluetoothAdapter.startDiscovery();
    } catch (SecurityException ignored) {
    }
  }

  private void stopScan() {
    if (mBluetoothAdapter == null) return;
    try {
      mBluetoothAdapter.cancelDiscovery();
    } catch (SecurityException | IllegalStateException ignored) {
    }
  }

  private void postState(final int stateValue) {
    new Handler(Looper.getMainLooper()).post(() -> {
      if (sink != null) {
        sink.success(stateValue);
      }
    });
  }

  public void connect(final String mac) {
    if (mac == null || context == null) return;
    PrinterDevices blueTooth = new PrinterDevices.Build()
            .setContext(context)
            .setConnMethod(ConnMethod.BLUETOOTH)
            .setMacAddress(mac)
            .setCommand(Command.ESC)
            .setCallbackListener(new CallbackListener() {
              @Override
              public void onConnecting() { }

              @Override
              public void onCheckCommand() { }

              @Override
              public void onSuccess(PrinterDevices printerDevices) {
                postState(BPPState.DeviceConnected.getValue());
              }

              @Override
              public void onReceive(byte[] data) {
                if (data == null) return;
                new Handler(Looper.getMainLooper()).post(() -> {
                  if (channel != null) {
                    channel.invokeMethod("ReceivedData", data);
                  }
                });
              }

              @Override
              public void onFailure() {
                postState(BPPState.DeviceDisconnected.getValue());
              }

              @Override
              public void onDisconnect() {
                postState(BPPState.DeviceDisconnected.getValue());
              }
            })
            .build();
    Printer.connect(blueTooth);
  }

  @SuppressWarnings("unchecked")
  private boolean write(byte[] data) throws IOException {
    PortManager pm = Printer.getPortManager();
    if (pm == null || data == null) {
      LogUtils.d(TAG, "发送失败: PortManager is null");
      return false;
    }
    boolean result = pm.writeDataImmediately(data);
    LogUtils.d(TAG, result ? "发送成功": "发送失败");
    return result;
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    LogUtils.d(TAG, "onRequestPermissionsResult");
    if (requestCode == REQUEST_LOCATION_PERMISSIONS) {
      if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        startScan();
      } else {
        pendingResult.error("no_permissions", "this plugin requires location permissions for scanning", null);
        pendingResult = null;
      }
      return true;
    }
    return false;
  }

  private final StreamHandler stateHandler = new StreamHandler() {
    // private EventSink sink;
    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        final String action = intent.getAction();
        // LogUtils.d(TAG, "stateStreamHandler, current action: " + action);
        if (BluetoothAdapter.ACTION_STATE_CHANGED.equals(action)) {
          int blueState = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, 0);
          switch (blueState) {
            case BluetoothAdapter.STATE_ON:
              sink.success(BPPState.BlueOn.getValue());
              break;
            case BluetoothAdapter.STATE_OFF:
              sink.success(BPPState.BlueOff.getValue());
              break;
          }
        }
      }
    };

    @Override
    public void onListen(Object o, EventSink eventSink) {
      sink = eventSink;
      try {
        IntentFilter filter = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
          context.registerReceiver(mReceiver, filter, Context.RECEIVER_EXPORTED);
        } else {
          context.registerReceiver(mReceiver, filter);
        }
      } catch (Exception ignored) {
      }
    }

    @Override
    public void onCancel(Object o) {
      sink = null;
      try {
        context.unregisterReceiver(mReceiver);
      } catch (Exception ignored) {
      }
    }
  };
}
