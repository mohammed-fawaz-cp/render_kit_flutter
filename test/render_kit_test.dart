import 'package:flutter_test/flutter_test.dart';
import 'package:render_kit/render_kit.dart';
import 'package:render_kit/render_kit_platform_interface.dart';
import 'package:render_kit/render_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRenderKitPlatform
    with MockPlatformInterfaceMixin
    implements RenderKitPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final RenderKitPlatform initialPlatform = RenderKitPlatform.instance;

  test('$MethodChannelRenderKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRenderKit>());
  });

  test('getPlatformVersion', () async {
    RenderKit renderKitPlugin = RenderKit();
    MockRenderKitPlatform fakePlatform = MockRenderKitPlatform();
    RenderKitPlatform.instance = fakePlatform;

    expect(await renderKitPlugin.getPlatformVersion(), '42');
  });
}
