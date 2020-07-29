
Pod::Spec.new do |s|
  s.name             = "ClusterKit"
  s.version          = "0.5.0"
  s.summary          = "ClusterKit is a map clustering framework targeting MapKit, Google Maps, Mapbox and YandexMapKit."

  s.description      = <<-DESC
                        ClusterKit is an efficient clustering framework with the following features:
                        - Native supports of MapKit, GoogleMaps, Mapbox and YandexMapKit.
                        - Comes with 2 clustering algorithms, a Grid Based Algorithm and a Non Hierarchical Distance Based Algorithm. Other algorithms can easily be integrated.
                        - Annotations are stored in a QuadTree for efficient region queries.
                        - Cluster center can be switched to Centroid, Nearest Centroid, Bottom.
                        - Handles pin selection as well as drag and dropping.
                        - Written in Objective-C with full Swift interop support.
                       DESC

  s.homepage         = "https://github.com/hulab/ClusterKit"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Hulab" => "info@mapstr.com" }
  s.source           = { :git => "https://github.com/hulab/ClusterKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mapstr_app'

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.default_subspecs = 'Core'
  
  s.subspec 'Core' do |ss|
    ss.frameworks = 'MapKit'
    ss.source_files = 'Sources/ClusterKit/**/*.{h,m}'

    ss.test_spec do |test_spec|
      test_spec.source_files = 'Tests/ClusterKitTests/*.{h,m}'
    end
  end

  # Like GoogleMaps sdk (googlemaps/google-maps-ios-utils#23) YandexMapKit is statically built,
  # which mean we can't use them as subspec dependency yet. Better to keep both
  # GoogleMaps and YandexMapKit commented until both of them are dynamically built!
  
  # s.subspec 'GoogleMaps' do |ss|
  #  ss.platform = :ios, '8.0'
  #  ss.dependency 'ClusterKit/Core'
  #  ss.dependency 'GoogleMaps', '~> 2.7'
  #  ss.source_files = 'Sources/GoogleMaps'
  # end

  # s.subspec 'YandexMapKit' do |ss|
  #   ss.platform = :ios, '9.0'
  #   ss.dependency 'ClusterKit/Core'
  #   ss.dependency 'YandexMapKit', '~> 3.2'
  #   ss.source_files = 'Sources/YandexMapKit'
  # end

  s.subspec 'Mapbox' do |ss|
    ss.platform = :ios, '9.0'
    ss.dependency 'ClusterKit/Core'
    ss.dependency 'Mapbox-iOS-SDK', '~> 5.0'
    ss.source_files = 'Sources/Mapbox'
  end

end
