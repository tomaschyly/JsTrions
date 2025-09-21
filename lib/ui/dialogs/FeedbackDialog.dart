import 'dart:io';

import 'package:js_trions/config.dart';
import 'package:js_trions/core/app_theme.dart';
import 'package:js_trions/model/dataTasks/HttpGetDataTask.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tch_appliable_core/tch_appliable_core.dart';
import 'package:tch_common_widgets/tch_common_widgets.dart';

class FeedbackDialog extends AbstractStatefulWidget {
  /// Show the dialog as a popup
  static Future<bool?> show(
    BuildContext context,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: FeedbackDialog(),
        );
      },
    );
  }

  /// Create state for widget
  @override
  State<StatefulWidget> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends AbstractStatefulWidgetState<FeedbackDialog> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _subjectFocus = FocusNode();
  final FocusNode _messageFocus = FocusNode();
  bool _gdpr = false;
  bool _gdprError = false;
  bool _isSending = false;

  /// Manually dispose of resources
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _subjectFocus.dispose();
    _messageFocus.dispose();

    super.dispose();
  }

  /// Create view layout from widgets
  @override
  Widget buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final commonTheme = CommonTheme.of<AppTheme>(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        alignment: Alignment.center,
        child: DialogContainer(
          style: commonTheme.dialogsStyle.listDialogStyle.dialogContainerStyle,
          content: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DialogHeader(
                    style: commonTheme.dialogsStyle.listDialogStyle.dialogHeaderStyle,
                    title: tt('feedback.title'),
                  ),
                  CommonSpaceVHalf(),
                  TextFormFieldWidget(
                    style: commonTheme.formStyle.textFormFieldStyle.copyWith(
                      textCapitalization: TextCapitalization.words,
                    ),
                    controller: _nameController,
                    focusNode: _nameFocus,
                    nextFocus: _emailFocus,
                    label: tt('feedback.name'),
                    textInputAction: TextInputAction.next,
                  ),
                  CommonSpaceVHalf(),
                  TextFormFieldWidget(
                    style: commonTheme.emailFormFieldStyle,
                    controller: _emailController,
                    focusNode: _emailFocus,
                    nextFocus: _subjectFocus,
                    label: tt('feedback.email'),
                    textInputAction: TextInputAction.next,
                  ),
                  CommonSpaceVHalf(),
                  TextFormFieldWidget(
                    style: commonTheme.formStyle.textFormFieldStyle.copyWith(
                      textCapitalization: TextCapitalization.words,
                    ),
                    controller: _subjectController,
                    focusNode: _subjectFocus,
                    nextFocus: _messageFocus,
                    label: tt('feedback.subject'),
                    textInputAction: TextInputAction.next,
                  ),
                  CommonSpaceVHalf(),
                  TextFormFieldWidget(
                    style: commonTheme.formStyle.textFormFieldStyle.copyWith(
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    controller: _messageController,
                    focusNode: _messageFocus,
                    label: tt('feedback.message'),
                    lines: 3,
                    validations: [
                      FormFieldValidation(
                        validator: validateRequired,
                        errorText: tt('validation.required'),
                      ),
                    ],
                  ),
                  CommonSpaceV(),
                  Container(
                    width: kPhoneStopBreakpoint,
                    child: AnimatedSize(
                      duration: kThemeAnimationDuration,
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Text(
                                  tt('feedback.gdpr'),
                                  style: fancyText(commonTheme.formStyle.textFormFieldStyle.inputDecoration.labelStyle!),
                                ),
                              ),
                              CommonSpaceH(),
                              SwitchToggleWidget(
                                initialValue: _gdpr,
                                onText: tt('feedback.gdpr.on'),
                                offText: tt('feedback.gdpr.off'),
                                onChange: (bool newValue) => setStateNotDisposed(() {
                                  _gdpr = newValue;
                                  _gdprError = false;
                                }),
                              ),
                            ],
                          ),
                          if (!_gdpr && _gdprError)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: kCommonHorizontalMarginHalf),
                              child: Text(
                                tt('feedback.gdpr.error'),
                                style: fancyText(kText.copyWith(color: Colors.red)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  CommonSpaceVHalf(),
                ],
              ),
            ),
          ],
          dialogFooter: DialogFooter(
            style: commonTheme.dialogsStyle.listDialogStyle.dialogFooterStyle,
            noText: tt('dialog.cancel'),
            yesText: tt('feedback.send'),
            noOnTap: () {
              Navigator.of(context).pop();
            },
            yesOnTap: () => _sendFeedback(context),
            yesIsLoading: _isSending,
          ),
        ),
      ),
    );
  }

  /// Validate and send to BE api
  Future<void> _sendFeedback(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (!_gdpr) {
      setStateNotDisposed(() {
        _gdprError = true;
      });
    }

    if (_formKey.currentState!.validate() && _gdpr) {
      setStateNotDisposed(() {
        _isSending = true;
      });

      final String name = _nameController.text.isNotEmpty ? _nameController.text : 'Anonymous';

      final String version = (await PackageInfo.fromPlatform()).version;

      final HttpGetDataTask dataTask = await MainDataProvider.instance!.executeDataTask(HttpGetDataTask(
        url: kFeedbackUrl,
        parameters: <String, String>{
          "app": 'js_trions',
          "version": version,
          "platform": Platform.operatingSystem.toLowerCase(),
          "name": name,
          "email": _emailController.text,
          "subject": _subjectController.text,
          "message": _messageController.text,
        },
      ));

      if (dataTask.result != null && (dataTask.result!.error == null || dataTask.result!.error?.isEmpty == true)) {
        setStateNotDisposed(() {
          _isSending = false;

          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            popNotDisposed(context, mounted, true);
          });
        });
      } else {
        setStateNotDisposed(() {
          _isSending = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            tt('feedback.submit.fail'),
            style: fancyText(kTextDanger),
            textAlign: TextAlign.center,
          ),
        ));
      }
    }
  }
}
