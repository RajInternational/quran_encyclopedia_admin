import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/AppSettingModel.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';

class AdminSettingScreen extends StatefulWidget {
  static String tag = '/AdminSettingScreen';

  @override
  _AdminSettingScreenState createState() => _AdminSettingScreenState();
}

class _AdminSettingScreenState extends State<AdminSettingScreen> {
  var formKey = GlobalKey<FormState>();

  TextEditingController termConditionCont = TextEditingController();
  TextEditingController privacyPolicyCont = TextEditingController();
  TextEditingController contactInfoCont = TextEditingController();

  bool? disableAd = false;

  String termCondition = '';
  String privacyPolicy = '';
  String contactInfo = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);

    await appSettingService.getAppSettings().then((value) async {
      disableAd = value.disableAd;
      termConditionCont.text = value.termCondition!;
      privacyPolicyCont.text = value.privacyPolicy!;
      contactInfoCont.text = value.contactInfo!;
    }).catchError((e) {
      toast(errorSomethingWentWrong);
    });

    appStore.setLoading(false);
  }

  Future<void> save() async {
    if (formKey.currentState!.validate()) {
      if (appStore.isTester) return toast(mTesterNotAllowedMsg);

      appStore.setLoading(true);

      AppSettingModel appSettingModel = AppSettingModel();

      appSettingModel.disableAd = disableAd;
      appSettingModel.termCondition = termConditionCont.text.trim();
      appSettingModel.privacyPolicy = privacyPolicyCont.text.trim();
      appSettingModel.contactInfo = contactInfoCont.text.trim();

      await appSettingService.updateDocument(appSettingModel.toJson(), appSettingService.id).then((value) async {
        await appSettingService.saveAppSettings(appSettingModel);

        toast('Successfully Saved');
      }).catchError((e) {
        e.toString().toastString();
      });

      appStore.setLoading(false);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 30, top: 16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 500,
                      child: Column(
                        children: [
                          AppTextField(
                            controller: termConditionCont,
                            textFieldType: TextFieldType.URL,
                            decoration: inputDecoration(labelText: 'Term Condition'),
                            validator: (s) {
                              if (s!.isEmpty) return errorThisFieldRequired;
                              if (!s.validateURL()) return 'URL is invalid';
                              return null;
                            },
                          ).paddingAll(16),
                          AppTextField(
                            controller: privacyPolicyCont,
                            textFieldType: TextFieldType.URL,
                            decoration: inputDecoration(labelText: 'privacyPolicy'),
                            validator: (s) {
                              if (s!.isEmpty) return errorThisFieldRequired;
                              if (!s.validateURL()) return 'URLURL is invalid';
                              return null;
                            },
                          ).paddingAll(16),
                          AppTextField(
                            controller: contactInfoCont,
                            textFieldType: TextFieldType.URL,
                            decoration: inputDecoration(labelText: 'Contact Info'),
                          ).paddingAll(16),
                          SettingItemWidget(
                            title: 'Disable AdMob',
                            leading: Checkbox(
                              value: disableAd,
                              onChanged: (v) {
                                disableAd = v;

                                setState(() {});
                              },
                            ),
                            onTap: () {
                              disableAd = !disableAd!;

                              setState(() {});
                            },
                          ),
                          AppButton(
                            text: 'save',
                            onTap: () => save(),
                            height: 60,
                            width: context.width(),
                          ).paddingAll(16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Observer(builder: (_) => Loader().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
