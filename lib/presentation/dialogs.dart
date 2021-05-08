import 'package:donation_tracker/_managers/donation_manager.dart';
import 'package:donation_tracker/models/donation.dart';
import 'package:donation_tracker/models/usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:layout/layout.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:reactive_forms/reactive_forms.dart';

const Radius _kDefaultBarTopRadius = Radius.circular(15);

Future<void> showAddEditUsageDlg(BuildContext context,
    {Usage? usage, bool waiting = false}) async {
  final form = FormGroup({
    'id': FormControl<int>(value: usage?.id),
    'receivers_name': FormControl<String>(value: usage?.name),
    'receivers_hidden_name': FormControl<String>(value: usage?.hiddenName),
    'usage': FormControl<String>(value: usage?.whatFor),
    'value': FormControl<double>(
        value: (usage?.amount ?? 0.0) / 100.0,
        validators: [Validators.required, Validators.number]),
    'usage_date': FormControl<DateTime>(
        value: usage?.date != null
            ? DateTime.tryParse(usage!.date!)
            : DateTime.now()),
    'storage_image_name': FormControl<String>(value: usage?.image),
    'storage_image_name_person':
        FormControl<String>(value: usage?.imageReceiver),
  });
  final shouldSave = await showFluidBarModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return UsageDialogContent(
          form: form,
          newUsage: usage == null,
          isWaitingEntry: waiting,
        );
      });
  if (shouldSave == true) {
    final newUsage = Usage(
        id: form.value['id'] as int?,
        name: form.value['receivers_name'] as String?,
        hiddenName: form.value['receivers_hidden_name'] as String?,
        amount: ((form.value['value'] as double) * 100.0).toInt(),
        date: waiting
            ? null
            : (form.value['usage_date'] as DateTime).toIso8601String(),
        whatFor: form.value['usage'] as String,
        image: form.value['storage_image_name'] as String?,
        imageReceiver: form.value['storage_image_name_person'] as String?);
    GetIt.I<DonationManager>().upsertUsage!(newUsage);
  }
}

class UsageDialogContent extends StatelessWidget {
  const UsageDialogContent(
      {Key? key,
      required this.form,
      required this.newUsage,
      required this.isWaitingEntry})
      : super(key: key);

  final FormGroup form;
  final bool newUsage;
  final bool isWaitingEntry;

  @override
  Widget build(BuildContext context) {
    late String headerText;
    if (isWaitingEntry) {
      if (newUsage) {
        headerText = 'Add new Waiting Cause';
      } else {
        headerText = 'Edit Waiting Cause';
      }
    } else {
      if (newUsage) {
        headerText = 'Add new Usage';
      } else {
        headerText = 'Edit Usage';
      }
    }
    return Container(
      color: Colors.blue.shade900,
      child: ReactiveForm(
        formGroup: form,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                headerText,
                style: Theme.of(context).textTheme.headline4,
              ),
              ReactiveTextField<int>(
                formControlName: 'id',
                decoration: InputDecoration(labelText: 'ID'),
                readOnly: true,
              ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'receivers_name',
                decoration: InputDecoration(labelText: 'Recivers Name'),
              ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'receivers_hidden_name',
                decoration: InputDecoration(labelText: 'Hidden Name'),
              ),
              SizedBox(height: 8),
              ReactiveTextField<double>(
                formControlName: 'value',
                decoration: InputDecoration(labelText: 'Amount'),
              ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'usage',
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 10,
              ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'storage_image_name',
                decoration: InputDecoration(
                  labelText: 'Image',
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.image_search,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'storage_image_name_person',
                decoration: InputDecoration(
                  labelText: 'Receiver\'s Image',
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.image_search,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              SizedBox(height: 8),
              ReactiveTextField<DateTime>(
                formControlName: 'usage_date',
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Birthday',
                  suffixIcon: ReactiveDatePicker<DateTime>(
                    firstDate: DateTime.now().subtract(Duration(days: 30)),
                    lastDate: DateTime.now(),
                    formControlName: 'usage_date',
                    builder: (context, picker, child) {
                      return IconButton(
                        onPressed: picker.showPicker,
                        icon: const Icon(Icons.date_range),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 48),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 8, right: 8, bottom: 9),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xff115FA7),
                      side:
                          BorderSide(color: const Color(0xff115FA7), width: 3),
                      shape: StadiumBorder(),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 8, right: 8, bottom: 9),
                      child: Text(
                        'Save',
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xff115FA7),
                      side:
                          BorderSide(color: const Color(0xff115FA7), width: 3),
                      shape: StadiumBorder(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showAddEditDonationDlg(BuildContext context,
    [Donation? donation]) async {
  final form = FormGroup({
    'id': FormControl<int>(value: donation?.id),
    'donator': FormControl<String>(value: donation?.name),
    'donator_hidden': FormControl<String>(value: donation?.hiddenName),
    'value': FormControl<double>(
        value: (donation?.amount ?? 0.0) / 100.0,
        validators: [Validators.required, Validators.number]),
    'donation_date': FormControl<DateTime>(
        value: donation?.date != null
            ? DateTime.tryParse(donation!.date)
            : DateTime.now()),
  });
  final shouldSave = await showFluidBarModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return DonationDialogContent(
          form: form,
          newDonation: donation == null,
        );
      });
  if (shouldSave == true) {
    final newDonation = Donation(
        id: form.value['id'] as int?,
        name: form.value['donator'] as String?,
        hiddenName: form.value['donator_hidden'] as String?,
        amount: ((form.value['value'] as double) * 100.0).toInt(),
        date: (form.value['donation_date'] as DateTime).toIso8601String());
    GetIt.I<DonationManager>().upsertDonation!(newDonation);
  }
}

class DonationDialogContent extends StatelessWidget {
  const DonationDialogContent(
      {Key? key, required this.form, required this.newDonation})
      : super(key: key);

  final FormGroup form;
  final bool newDonation;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade900,
      child: ReactiveForm(
        formGroup: form,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                newDonation ? 'Add Donation' : 'Edit Donation',
                style: Theme.of(context).textTheme.headline4,
              ),
              ReactiveTextField<int>(
                formControlName: 'id',
                decoration: InputDecoration(labelText: 'ID'),
                readOnly: true,
              ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'donator',
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 8),
              ReactiveTextField<String>(
                formControlName: 'donator_hidden',
                decoration: InputDecoration(labelText: 'Hidden Name'),
              ),
              SizedBox(height: 8),
              ReactiveTextField<double>(
                formControlName: 'value',
                decoration: InputDecoration(labelText: 'Amount'),
              ),
              SizedBox(height: 8),
              ReactiveTextField<DateTime>(
                formControlName: 'donation_date',
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Birthday',
                  suffixIcon: ReactiveDatePicker<DateTime>(
                    firstDate: DateTime.now().subtract(Duration(days: 30)),
                    lastDate: DateTime.now(),
                    formControlName: 'donation_date',
                    builder: (context, picker, child) {
                      return IconButton(
                        onPressed: picker.showPicker,
                        icon: const Icon(Icons.date_range),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 48),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 8, right: 8, bottom: 9),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xff115FA7),
                      side:
                          BorderSide(color: const Color(0xff115FA7), width: 3),
                      shape: StadiumBorder(),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 8, right: 8, bottom: 9),
                      child: Text(
                        'Save',
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xff115FA7),
                      side:
                          BorderSide(color: const Color(0xff115FA7), width: 3),
                      shape: StadiumBorder(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BarBottomSheet extends StatelessWidget {
  final Widget child;
  final Widget? control;
  final Clip? clipBehavior;
  final double? elevation;
  final ShapeBorder? shape;
  final bool expanded;
  final bool notTopControl;

  const BarBottomSheet(
      {Key? key,
      required this.child,
      this.control,
      this.clipBehavior,
      this.shape,
      this.elevation,
      this.expanded = false,
      this.notTopControl = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayAsDialog =
        context.layout.value(xs: false, sm: false, md: true);
    final borderRadius = displayAsDialog
        ? const BorderRadius.all(_kDefaultBarTopRadius)
        : const BorderRadius.only(
            topLeft: _kDefaultBarTopRadius,
            topRight: _kDefaultBarTopRadius,
          );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Align(
        alignment: displayAsDialog ? Alignment.center : Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: displayAsDialog
              ? MainAxisAlignment.center
              : MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (displayAsDialog || !notTopControl)
              const SizedBox(
                height: 12,
              ),
            if (!displayAsDialog && !notTopControl) ...[
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  bottom: false,
                  child: control ??
                      Container(
                        height: 6,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 8)
            ],
            Flexible(
              fit: FlexFit.loose,
              child: Material(
                shape:
                    shape ?? RoundedRectangleBorder(borderRadius: borderRadius),
                clipBehavior: clipBehavior ?? Clip.hardEdge,
                elevation: elevation ?? 2,
                child: SizedBox(
                  width: double.infinity,
                  height: displayAsDialog || !expanded ? null : double.infinity,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: child,
                  ),
                ),
              ),
            ),
            SizedBox(height: displayAsDialog ? 20 : 0),
          ],
        ),
      ),
    );
  }
}

class SheetFluidFormat extends FluidLayoutFormat {
  @override
  Map<LayoutBreakpoint, double> get maxFluidWidth => {
        LayoutBreakpoint.xs: 576,
        LayoutBreakpoint.sm: 720,
        LayoutBreakpoint.md: 720,
        LayoutBreakpoint.lg: 720,
        LayoutBreakpoint.xl: 720
      };

  @override
  LayoutValue<double> get margin => LayoutValue.constant(0);
}

Future<T?> showFluidBarModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  double? closeProgressThreshold,
  Clip? clipBehavior,
  Color barrierColor = Colors.black87,
  bool bounce = true,
  bool expand = false,
  AnimationController? secondAnimation,
  Curve? animationCurve,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Widget? topControl,
  Duration? duration,
  double? maxWidth,
  bool noTopControl = true,
}) async {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));
  final result = await Navigator.of(context, rootNavigator: useRootNavigator)
      .push(ModalBottomSheetRoute<T>(
    builder: builder,
    bounce: bounce,
    closeProgressThreshold: closeProgressThreshold,
    containerBuilder: (_, __, child) => Layout(
      format: SheetFluidFormat(),
      child: FluidMargin(
        maxWidth: maxWidth,
        child: BarBottomSheet(
          notTopControl: noTopControl,
          control: topControl,
          clipBehavior: clipBehavior,
          shape: shape,
          elevation: elevation,
          expanded: expand,
          child: child,
        ),
      ),
    ),
    secondAnimationController: secondAnimation,
    expanded: expand,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
    animationCurve: animationCurve,
    duration: duration,
  ));
  return result;
}

Future<bool> showQueryDialog(BuildContext context, String title, String message,
    {String trueText = 'Yes', String falseText = 'Cancel'}) async {
  return (await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(trueText),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(falseText),
            ),
          ],
        );
      }))!;
}