
Pod::Spec.new do |s|
  s.name             = "ClusterKit"
  s.version          = "0.1.2"
  s.summary          = "ClusterKit is a map clustering framework targeting MapKit and Google Maps."

  s.description      = <<-DESC
                        ClusterKit is an efficient clustering framework with the following features:
                        - Supports MapKit AND GoogleMaps.
                        - Comes with 2 clustering algorithms, a Grid Based Algorithm and a Non Hierarchical Distance Based Algorithm. Other algorithms can easily be integrated.
                        - Annotations are stored in a QuadTree for efficient region queries.
                        - Cluster center can be switched to Centroid, Nearest Centroid, Bottom.
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
    ss.source_files = 'ClusterKit/ClusterKit.h', 'ClusterKit/Core/**/*.{h,m}'
  end
  
  s.subspec 'MapKit' do |ss|
    ss.dependency 'ClusterKit/Core'
    ss.source_files = 'ClusterKit/MapKit'
  end
  
#  s.subspec 'GoogleMaps' do |ss|
#    ss.dependency 'ClusterKit/Core'
#    ss.dependency 'GoogleMaps', '~> 2.1'
#    ss.source_files = 'ClusterKit/GoogleMaps'
#  end
  
end
