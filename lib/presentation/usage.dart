import 'package:donation_tracker/donation_manager.dart';
import 'package:donation_tracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class DonationUsages extends StatelessWidget with GetItMixin {
  @override
  Widget build(BuildContext context) {
    final usages = watchX((DonationManager d) => d.usageUpdates);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        DefaultTextStyle.merge(
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          child: Row(
            children: const [
              Expanded(child: Text('Date')),
              Expanded(child: Text('Amount')),
              Expanded(child: Text('Usage')),
              Expanded(child: Text('Recipient')),
              Spacer(),
            ],
          ),
        ),
        Expanded(
          child: ListView(
              children: usages.map(
            (data) {
              return Row(
                children: [
                  Expanded(
                      child:
                          Text(data.date?.toDateTime().format() ?? 'missing')),
                  Expanded(child: Text(data.amount.toCurrency())),
                  Expanded(child: Text(data.whatFor)),
                  // Expanded(child: Text(data.),)
                  Expanded(
                    child: InkWell(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: 100, maxHeight: 60),
                        child: data.imageLink == null
                            ? Container()
                            : Image.network(
                                data.imageLink!,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                fit: BoxFit.contain,
                              ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Image.network(
                                data.imageLink!,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                fit: BoxFit.contain,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Close'),
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ).toList()),
        )
      ]),
    );
  }
}
