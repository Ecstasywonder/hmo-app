import '/components/logo_wordmark_widget.dart';
import '/components/slogan_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'splash_screen_widget.dart' show SplashScreenWidget;
import 'package:flutter/material.dart';

class SplashScreenModel extends FlutterFlowModel<SplashScreenWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for LogoWordmark component.
  late LogoWordmarkModel logoWordmarkModel;
  // Model for Slogan component.
  late SloganModel sloganModel;

  @override
  void initState(BuildContext context) {
    logoWordmarkModel = createModel(context, () => LogoWordmarkModel());
    sloganModel = createModel(context, () => SloganModel());
  }

  @override
  void dispose() {
    logoWordmarkModel.dispose();
    sloganModel.dispose();
  }
}
