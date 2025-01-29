// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';

import 'no_data.dart';

class ScrollablePagewiseListView extends StatelessWidget {
  Future<void> Function() onRefresh;
  PagewiseLoadController<dynamic>? pageLoadController;
  Widget Function(dynamic) itemBuilder;
  Widget loadingViewWidget;
  final String errorMessage;

  ScrollablePagewiseListView({
    Key? key,
    required this.onRefresh,
    required this.pageLoadController,
    required this.itemBuilder,
    required this.loadingViewWidget,
    this.errorMessage = 'No Items Found',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: PagewiseListView(
        shrinkWrap: true,
        pageLoadController: pageLoadController,
        itemBuilder: ((__, entry, _) {
          // var e = entry as Checkin;
          return itemBuilder(entry);
        }),
        loadingBuilder: (context) {
          if (pageLoadController!.numberOfLoadedPages! > 0) {
            return Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.only(bottom: 90),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return loadingViewWidget;
        },
        noItemsFoundBuilder: (context) {
          return NoData(message: errorMessage);
        },
        retryBuilder: (context, retryFunction) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error loading data. Please try again later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: retryFunction,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
