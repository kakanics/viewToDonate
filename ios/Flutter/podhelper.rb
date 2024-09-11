def flutter_install_all_ios_pods(flutter_application_path)
    require File.expand_path('Flutter/Flutter.framework', flutter_application_path)
    require File.expand_path('Flutter/Flutter.framework/Headers/Flutter.h', flutter_application_path)
    require File.expand_path('Flutter/Flutter.framework/Headers/FlutterPlugin.h', flutter_application_path)
  end
  