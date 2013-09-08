//# Modified for Whonix, see COPYING for copying conditions.

loadTemplate("org.kde.plasma-desktop.defaultPanel")

for (var i = 0; i < screenCount; ++i) {
    // Whonix changes to 00-defaultLayout.js
    //var activity = new Activity
    var activity = new Activity("folderview")
    activity.wallpaperPlugin = "image"
    activity.wallpaperMode = "SingleImage"
    activity.currentConfigGroup = Array("Wallpaper", "image")
    activity.writeConfig("wallpaper", "/usr/share/wallpapers/stripes.png")
    // End of Whonix changes to 00-defaultLayout.js
    desktop.name = i18n("Desktop")
    desktop.screen = i
    desktop.wallpaperPlugin = 'image'
    desktop.wallpaperMode = 'SingleImage'

    //Create more panels for other screens
    if (i > 0){
        var panel = new Panel
        panel.screen = i
        panel.location = 'bottom'
        panel.height = panels()[i].height = screenGeometry(0).height >
1024 ? 35 : 27
        var tasks = panel.addWidget("tasks")
        tasks.writeConfig("showOnlyCurrentScreen", true);
    }
}
