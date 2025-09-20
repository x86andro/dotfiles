# requires: python3-pydbus, GLib
from pydbus import SessionBus
from gi.repository import GLib
import sys, ast, re

side = (sys.argv[1].lower() if len(sys.argv) > 1 else "left")
bus = SessionBus()
loop = GLib.MainLoop()

watcher = bus.get("org.kde.StatusNotifierWatcher", "/StatusNotifierWatcher")

def emit(text: str):
    sys.stdout.write('{"text": "%s"}\n' % text)
    sys.stdout.flush()

def update():
    try:
        items_variant = watcher.Get("org.kde.StatusNotifierWatcher",
                                    "RegisteredStatusNotifierItems")
        items = list(items_variant) if items_variant else []
        if items:
            emit("[" if side == "left" else "]")
        else:
            emit("")
    except Exception:
        emit("")

update()

def on_changed():
    update()

bus.subscribe(
    iface="org.freedesktop.DBus.Properties",
    signal="PropertiesChanged",
    object="/StatusNotifierWatcher",
    arg0="org.kde.StatusNotifierWatcher",
    signal_fired=lambda *a, **kw: on_changed()
)

loop.run()
