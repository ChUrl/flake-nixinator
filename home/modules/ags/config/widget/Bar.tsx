import { App, Astal, Gtk, Gdk } from "astal/gtk4"
import { GLib, Variable } from "astal"
import { SysTray } from "./SysTray";

const user = Variable("")
    .poll(60000, ["bash", "-c", "whoami"]);

const time = Variable("")
    .poll(1000, ["bash", "-c", "date +'%H:%M:%S'"]);

const date = Variable("")
    .poll(60000, ["bash", "-c", "date +'%y-%m-%d'"])

const uptime = Variable("")
    .poll(60000, ["bash", "-c", "uptime | awk -F'( |,)+' '{print $4}'"]);

export default function Bar(gdkmonitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        cssClasses={["Window"]}
        application={App}
        gdkmonitor={gdkmonitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | LEFT | RIGHT}
        visible

        child={
            <centerbox
                cssClasses={["Bar"]}

                startWidget={
                    <box
                        halign={Gtk.Align.START}
                        children={[
                            <button
                                cssClasses={["LauncherButton"]}
                                onClicked="rofi -drun-show-actions -show drun"
                                cursor={Gdk.Cursor.new_from_name("pointer", null)}
                                label={""}
                            />,

                            <label
                                cssClasses={["UserLabel"]}
                                label={user((value) => `${value.toUpperCase()}`)}
                            />,

                            <label
                                cssClasses={["UptimeLabel"]}
                                label={uptime((value) => `${value}`)}
                            />,

                            <label
                                cssClasses={["WindowNameLabel"]}
                                label={"WINDOW"}
                            />
                        ]}
                    />
                }

                centerWidget={
                    <box />
                }

                endWidget={
                    <box
                        halign={Gtk.Align.START}
                        children={[
                            <SysTray />
                        ]}
                    />
                }
            />
        }
    />
}
