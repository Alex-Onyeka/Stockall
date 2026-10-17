import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

// Shared copy of the Items Report's searchable dropdown, for the
// report tables. The Items Report keeps its own private copy.

class ReportSearchableOption<T> {
  final T value;
  final String label;

  const ReportSearchableOption({
    required this.value,
    required this.label,
  });
}

class _ReportDropdownSelectionResult<T> {
  final T value;
  const _ReportDropdownSelectionResult(this.value);
}

class ReportSearchableDropdown<T> extends StatefulWidget {
  final String title;
  final T value;
  final List<ReportSearchableOption<T>> options;
  final ValueChanged<T> onChanged;
  final ThemeProvider theme;
  final String? searchHint;
  final bool showSearch;

  /// Accent border when a filter is set. Defaults to
  /// `value != null`.
  final bool? highlighted;

  const ReportSearchableDropdown({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.theme,
    this.searchHint,
    this.showSearch = true,
    this.highlighted,
  });

  @override
  State<ReportSearchableDropdown<T>> createState() =>
      _ReportSearchableDropdownState<T>();
}

class _ReportSearchableDropdownState<T>
    extends State<ReportSearchableDropdown<T>> {
  Future<void> _openPicker() async {
    final renderBox =
        context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;
    final triggerOffset = renderBox.localToGlobal(
      Offset.zero,
    );
    final triggerSize = renderBox.size;

    final result =
        await showDialog<_ReportDropdownSelectionResult<T>>(
          context: context,
          barrierColor: Colors.black.withAlpha(25),
          barrierDismissible: true,
          builder: (ctx) {
            return _ReportSearchableDropdownPopup<T>(
              triggerOffset: triggerOffset,
              triggerSize: triggerSize,
              title: widget.title,
              currentValue: widget.value,
              options: widget.options,
              searchHint: widget.searchHint,
              showSearch: widget.showSearch,
              theme: widget.theme,
            );
          },
        );

    if (result != null) {
      widget.onChanged(result.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final accent = theme.lightModeColor.prColor300;

    ReportSearchableOption<T>? selectedOption;
    for (final opt in widget.options) {
      if (opt.value == widget.value) {
        selectedOption = opt;
        break;
      }
    }
    selectedOption ??=
        widget.options.isNotEmpty
            ? widget.options.first
            : ReportSearchableOption(
              value: widget.value,
              label: '',
            );

    final bool isHighlighted =
        widget.highlighted ?? widget.value != null;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color:
                isHighlighted
                    ? accent.withAlpha(90)
                    : Colors.transparent,
            width: 1,
          ),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(5),
          onTap: _openPicker,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedOption.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isHighlighted
                              ? FontWeight.w600
                              : FontWeight.normal,
                      color:
                          isHighlighted
                              ? accent
                              : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 20,
                  color:
                      isHighlighted
                          ? accent
                          : Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportSearchableDropdownPopup<T>
    extends StatefulWidget {
  final Offset triggerOffset;
  final Size triggerSize;
  final String title;
  final T currentValue;
  final List<ReportSearchableOption<T>> options;
  final String? searchHint;
  final bool showSearch;
  final ThemeProvider theme;

  const _ReportSearchableDropdownPopup({
    super.key,
    required this.triggerOffset,
    required this.triggerSize,
    required this.title,
    required this.currentValue,
    required this.options,
    this.searchHint,
    this.showSearch = true,
    required this.theme,
  });

  @override
  State<_ReportSearchableDropdownPopup<T>> createState() =>
      _ReportSearchableDropdownPopupState<T>();
}

class _ReportSearchableDropdownPopupState<T>
    extends State<_ReportSearchableDropdownPopup<T>> {
  late final TextEditingController _searchCtrl;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _searchCtrl.addListener(() {
      final text = _searchCtrl.text.trim().toLowerCase();
      if (_query != text) {
        setState(() {
          _query = text;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.showSearch) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<ReportSearchableOption<T>> _getFilteredOptions() {
    if (_query.isEmpty) {
      return widget.options;
    }
    return widget.options.where((opt) {
      return opt.label.toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenSize = media.size;
    final viewInsets = media.viewInsets;
    final theme = widget.theme;
    final accent = theme.lightModeColor.prColor300;

    final filtered = _getFilteredOptions();

    final isMobile = screenSize.width < 520;

    final double popupWidth =
        isMobile
            ? (screenSize.width - 32.0).clamp(260.0, 420.0)
            : math
                .max(widget.triggerSize.width, 280.0)
                .clamp(240.0, screenSize.width - 32.0);

    final double left =
        isMobile
            ? (screenSize.width - popupWidth) / 2
            : widget.triggerOffset.dx.clamp(
              16.0,
              screenSize.width - popupWidth - 16.0,
            );

    final double maxPossibleHeight = math.min(
      380.0,
      screenSize.height - viewInsets.bottom - 40.0,
    );

    final double spaceBelow =
        screenSize.height -
        viewInsets.bottom -
        (widget.triggerOffset.dy +
            widget.triggerSize.height) -
        16.0;
    final double spaceAbove =
        widget.triggerOffset.dy - 16.0;

    final bool placeBelow =
        isMobile
            ? false
            : (spaceBelow >= 240.0 ||
                spaceBelow >= spaceAbove);

    final double? top =
        isMobile
            ? ((screenSize.height -
                        viewInsets.bottom -
                        maxPossibleHeight) /
                    2)
                .clamp(
                  20.0,
                  screenSize.height -
                      maxPossibleHeight -
                      20.0,
                )
            : (placeBelow
                ? widget.triggerOffset.dy +
                    widget.triggerSize.height +
                    4.0
                : null);

    final double? bottom =
        (!isMobile && !placeBelow)
            ? (screenSize.height -
                widget.triggerOffset.dy +
                4.0)
            : null;

    final double availableHeight =
        isMobile
            ? maxPossibleHeight
            : (placeBelow ? spaceBelow : spaceAbove).clamp(
              180.0,
              maxPossibleHeight,
            );

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            bottom: bottom,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: popupWidth,
                constraints: BoxConstraints(
                  maxHeight: availableHeight,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(45),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          12,
                          8,
                          6,
                          4,
                        ),
                        child: Row(
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 16,
                              ),
                              padding: EdgeInsets.zero,
                              constraints:
                                  const BoxConstraints(
                                    minWidth: 26,
                                    minHeight: 26,
                                  ),
                              splashRadius: 14,
                              color: Colors.grey.shade600,
                              onPressed:
                                  () =>
                                      Navigator.of(
                                        context,
                                      ).pop(),
                            ),
                          ],
                        ),
                      ),
                      if (widget.showSearch)
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                                10,
                                2,
                                10,
                                8,
                              ),
                          child: SizedBox(
                            height: 34,
                            child: TextField(
                              controller: _searchCtrl,
                              focusNode: _focusNode,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              textInputAction:
                                  TextInputAction.search,
                              onSubmitted: (_) {
                                if (filtered.isNotEmpty) {
                                  Navigator.of(context).pop(
                                    _ReportDropdownSelectionResult<
                                      T
                                    >(filtered.first.value),
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                hintText:
                                    widget.searchHint ??
                                    'Search ${widget.title.toLowerCase()}...',
                                hintStyle: TextStyle(
                                  fontSize: 11,
                                  color:
                                      Colors.grey.shade500,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                suffixIcon:
                                    _searchCtrl
                                            .text
                                            .isNotEmpty
                                        ? IconButton(
                                          icon: const Icon(
                                            Icons
                                                .close_rounded,
                                            size: 14,
                                          ),
                                          padding:
                                              EdgeInsets
                                                  .zero,
                                          splashRadius: 14,
                                          onPressed: () {
                                            _searchCtrl
                                                .clear();
                                          },
                                        )
                                        : null,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 0,
                                    ),
                                filled: true,
                                fillColor:
                                    Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                        6,
                                      ),
                                  borderSide: BorderSide(
                                    color:
                                        Colors
                                            .grey
                                            .shade300,
                                  ),
                                ),
                                enabledBorder:
                                    OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                            6,
                                          ),
                                      borderSide: BorderSide(
                                        color:
                                            Colors
                                                .grey
                                                .shade300,
                                      ),
                                    ),
                                focusedBorder:
                                    OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                            6,
                                          ),
                                      borderSide:
                                          BorderSide(
                                            color: accent,
                                            width: 1.5,
                                          ),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFEEEEEE),
                      ),
                      Flexible(
                        child:
                            filtered.isEmpty
                                ? Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 24,
                                        horizontal: 16,
                                      ),
                                  alignment:
                                      Alignment.center,
                                  child: Column(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons
                                            .search_off_rounded,
                                        size: 26,
                                        color:
                                            Colors
                                                .grey
                                                .shade400,
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Text(
                                        'No matches found',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade600,
                                          fontWeight:
                                              FontWeight
                                                  .w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : Scrollbar(
                                  controller: _scrollCtrl,
                                  thumbVisibility: true,
                                  child: ListView.builder(
                                    controller: _scrollCtrl,
                                    shrinkWrap: true,
                                    itemCount:
                                        filtered.length,
                                    padding:
                                        const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                    itemBuilder: (
                                      ctx,
                                      index,
                                    ) {
                                      final opt =
                                          filtered[index];
                                      final isSelected =
                                          opt.value ==
                                          widget
                                              .currentValue;

                                      return Material(
                                        color:
                                            isSelected
                                                ? accent
                                                    .withAlpha(
                                                      20,
                                                    )
                                                : Colors
                                                    .transparent,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(
                                              context,
                                            ).pop(
                                              _ReportDropdownSelectionResult<
                                                T
                                              >(opt.value),
                                            );
                                          },
                                          hoverColor: accent
                                              .withAlpha(
                                                12,
                                              ),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal:
                                                      12,
                                                  vertical:
                                                      8,
                                                ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 18,
                                                  child:
                                                      isSelected
                                                          ? Icon(
                                                            Icons.check_rounded,
                                                            size:
                                                                16,
                                                            color:
                                                                accent,
                                                          )
                                                          : null,
                                                ),
                                                const SizedBox(
                                                  width: 6,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    opt.label,
                                                    style: TextStyle(
                                                      fontSize:
                                                          12,
                                                      fontWeight:
                                                          isSelected
                                                              ? FontWeight.bold
                                                              : FontWeight.normal,
                                                      color:
                                                          isSelected
                                                              ? accent
                                                              : Colors.black87,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                      ),
                      if (widget.options.length > 6)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Text(
                                _query.isEmpty
                                    ? '${widget.options.length} ${widget.title.toLowerCase()}${widget.options.length == 1 ? '' : 's'}'
                                    : '${filtered.length} of ${widget.options.length}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      Colors.grey.shade600,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                              if (_query.isNotEmpty)
                                InkWell(
                                  onTap:
                                      () =>
                                          _searchCtrl
                                              .clear(),
                                  child: Text(
                                    'Clear search',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: accent,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
