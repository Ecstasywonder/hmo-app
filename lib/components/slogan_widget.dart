import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'slogan_model.dart';
export 'slogan_model.dart';

class SloganWidget extends StatefulWidget {
  const SloganWidget({super.key});

  @override
  State<SloganWidget> createState() => _SloganWidgetState();
}

class _SloganWidgetState extends State<SloganWidget> {
  late SloganModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SloganModel());

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
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 5.0, 16.0, 0.0),
      child: Text(
        'Connecting Health & Care',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Inter',
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
      ),
    );
  }
}
