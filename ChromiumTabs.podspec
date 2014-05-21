Pod::Spec.new do |spec|
  spec.name         = 'ChromiumTabs'
  spec.version      = '0.0.1'
  spec.license      = { :type => 'BSD' }
  spec.homepage     = 'https://github.com/rsms/chromium-tabs'
  spec.authors      = { 'Rasmus Andersson' => 'asmus@notion.se', 'Mark Aufflick' => 'mark@htb.io' }
  spec.summary      = 'Chromium tabs for cocoa applications.'
  spec.source       = { :git => 'https://github.com/aufflick/chromium-tabs.git', :tag => 'v0.0.1' }
  spec.source_files = 'src/**/*.{h,m,c}'
  spec.resources    = 'resources/**/*.{xib,pdf,png}'
  spec.framework    = 'QuartzCore'
  spec.requires_arc = true
  spec.prefix_header_contents = '#import "common.h"'
end

#
# TODO: need to migrate podspec to use external dependencies for thrid_party dir contents - GTM at least
#
