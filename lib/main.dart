import 'package:donation_tracker/constants.dart';
import 'package:donation_tracker/donation_manager.dart';
import 'package:donation_tracker/presentation/donations.dart';
import 'package:donation_tracker/presentation/usage.dart';
import 'package:donation_tracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import 'nhost_service.dart';

void main() {
  GetIt.I.registerSingleton(NhostService());
  GetIt.I.registerSingleton(DonationManager());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usage overview of DevsHelpDevs\'donations',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final controller =
      TabController(initialIndex: 0, length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(),
              SafeArea(
                child: TabBar(tabs: [
                  Tab(
                    child: Text('Received Donations'.toUpperCase()),
                  ),
                  Tab(
                    child: Text('Used for'.toUpperCase()),
                  )
                ], controller: controller),
              ),
              Expanded(
                child: TabBarView(
                  controller: controller,
                  children: [
                    Donations(),
                    DonationUsages(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _Header extends StatelessWidget with GetItMixin {
  _Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalDonated = watchX((DonationManager m) => m.totalDonated);
    final totalUsed = watchX((DonationManager m) => m.totalUsed);
    final totalWaiting = watchX((DonationManager m) => m.totalWaiting);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TotalLine(
                value: totalDonated,
                valueName: 'donated',
              ),
              _TotalLine(
                value: totalUsed,
                valueName: 'used',
              ),
              _TotalLine(
                value: totalWaiting,
                valueName: 'waiting',
              ),
            ],
          ),
        ),
        const Spacer(
          flex: 2,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SvgPicture.asset(
            'assets/images/devshelpdevs-logo.svg',
            height: 100,
          ),
        ),
      ],
    );
  }
}

class _TotalLine extends StatelessWidget {
  const _TotalLine({
    Key? key,
    required this.value,
    required this.valueName,
  }) : super(key: key);

  final int value;
  final valueName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total $valueName:'),
          Text(
            '${value.toCurrency()}',
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
