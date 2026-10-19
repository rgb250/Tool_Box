# Source - https://stackoverflow.com/a/79565372
# Posted by twj, modified by community. See post 'Timeline' for change history
# Retrieved 2026-04-07, License - CC BY-SA 4.0

unique_identifier = 'teradatacorporation.teradata-sql'
version = '1.1.0'
target_platform = ''

publisher, package = unique_identifier.split('.')
url = (
    f'https://marketplace.visualstudio.com/_apis/public/gallery/publishers/{publisher}/vsextensions/{package}/{version}/vspackage'
    + (f'?targetPlatform={target_platform}' if target_platform else ''))
print(url)
