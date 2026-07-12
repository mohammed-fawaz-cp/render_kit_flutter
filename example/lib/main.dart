import 'package:flutter/material.dart';
import 'package:render_kit_flutter/render_kit.dart';

void main() {
  runApp(const MyApp());
}

class AcceptCallAction extends RenderAction {
  const AcceptCallAction();
  @override
  Map<String, dynamic> toJson() => {'name': 'AcceptCallAction'};
}

class RejectCallAction extends RenderAction {
  const RejectCallAction();
  @override
  Map<String, dynamic> toJson() => {'name': 'RejectCallAction'};
}

@RenderEntry()
class IncomingCallScreen extends RenderWidget {
  const IncomingCallScreen();

  @override
  RenderWidget build(BuildContext context) {
    return RenderCenter(
      child: RenderCard(
        child: RenderPadding(
          padding: const RenderInsets.all(24.0),
          child: RenderColumn(
            children: [
              const RenderCircleAvatar(
                radius: 40.0,
              ),
              const RenderSpacer(),
              const RenderText(
                RenderBind<String>("callerName"),
                style: RenderTextStyle(
                  fontSize: 24.0,
                  bold: true,
                ),
              ),
              const RenderSpacer(),
              RenderRow(
                children: [
                  RenderButton(
                    action: const AcceptCallAction(),
                    text: "Accept",
                  ),
                  const RenderSpacer(),
                  RenderButton(
                    action: const RejectCallAction(),
                    text: "Reject",
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _lastEvent = 'No events yet';

  @override
  void initState() {
    super.initState();
    RenderKit.events.listen((event) {
      setState(() {
        _lastEvent = 'Received action: ${event.action.runtimeType}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: const Text('RenderKit Flutter Preview')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 320,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const RenderPreview(
                  state: {
                    'callerName': 'John Doe',
                  },
                  child: IncomingCallScreen(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _lastEvent,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
