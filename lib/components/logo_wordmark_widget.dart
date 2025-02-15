import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'logo_wordmark_model.dart';
export 'logo_wordmark_model.dart';

class LogoWordmarkWidget extends StatefulWidget {
  const LogoWordmarkWidget({super.key});

  @override
  State<LogoWordmarkWidget> createState() => _LogoWordmarkWidgetState();
}

class _LogoWordmarkWidgetState extends State<LogoWordmarkWidget> {
  late LogoWordmarkModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LogoWordmarkModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 16.0, 0.0),
      child: Text(
        'CareLink',
        style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Inter Tight',
              color: FlutterFlowTheme.of(context).primary,
              letterSpacing: 0.0,
            ),
      ),
    );
  }
}
