import '/components/logo_wordmark_widget.dart';
import '/components/slogan_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'auth2_widget.dart' show Auth2Widget;
import 'package:flutter/material.dart';

class Auth2Model extends FlutterFlowModel<Auth2Widget> {
  ///  State fields for stateful widgets in this page.

  // Model for LogoWordmark component.
  late LogoWordmarkModel logoWordmarkModel;
  // Model for Slogan component.
  late SloganModel sloganModel;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;
  // State field(s) for emailAddress_Create widget.
  FocusNode? emailAddressCreateFocusNode1;
  TextEditingController? emailAddressCreateTextController1;
  String? Function(BuildContext, String?)?
      emailAddressCreateTextController1Validator;
  // State field(s) for emailAddress_Create widget.
  FocusNode? emailAddressCreateFocusNode2;
  TextEditingController? emailAddressCreateTextController2;
  String? Function(BuildContext, String?)?
      emailAddressCreateTextController2Validator;
  // State field(s) for password_Create widget.
  FocusNode? passwordCreateFocusNode;
  TextEditingController? passwordCreateTextController;
  late bool passwordCreateVisibility;
  String? Function(BuildContext, String?)?
      passwordCreateTextControllerValidator;
  // State field(s) for passwordConfirm widget.
  FocusNode? passwordConfirmFocusNode;
  TextEditingController? passwordConfirmTextController;
  late bool passwordConfirmVisibility;
  String? Function(BuildContext, String?)?
      passwordConfirmTextControllerValidator;
  // State field(s) for Checkbox widget.
  bool? checkboxValue;

  @override
  void initState(BuildContext context) {
    logoWordmarkModel = createModel(context, () => LogoWordmarkModel());
    sloganModel = createModel(context, () => SloganModel());
    passwordVisibility = false;
    passwordCreateVisibility = false;
    passwordConfirmVisibility = false;
  }

  @override
  void dispose() {
    logoWordmarkModel.dispose();
    sloganModel.dispose();
    tabBarController?.dispose();
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();

    emailAddressCreateFocusNode1?.dispose();
    emailAddressCreateTextController1?.dispose();

    emailAddressCreateFocusNode2?.dispose();
    emailAddressCreateTextController2?.dispose();

    passwordCreateFocusNode?.dispose();
    passwordCreateTextController?.dispose();

    passwordConfirmFocusNode?.dispose();
    passwordConfirmTextController?.dispose();
  }
}
