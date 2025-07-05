import { Variable, bind } from "astal";
import { Gtk } from "astal/gtk4"
import AstalTray from "gi://AstalTray";

export function SysTray() {
    const tray = AstalTray.get_default()

    const trayIcons = Variable.derive(
        [bind(tray, "items")],
        (items) => {
            return items.map((item) => {
                return (
                    <menubutton
                        item={item}
                        child={
                            <image gicon={bind(item, "gicon")} />
                        }
                    />
                );
            });
        },
    );

    return <box
        cssClasses={["SysTray"]}
        children={
            bind(tray, "items").as(items => items.map(item => (
                <menubutton
                    tooltipMarkup={bind(item, "tooltipMarkup")}
                    usePopover={false}
                    actionGroup={bind(item, "actionGroup").as(ag => ["dbusmenu", ag])}
                    menuModel={bind(item, "menuModel")}
                    child={
                        <image gicon={bind(item, "gicon")} />
                    }
                />
            )))
        }
    />
}
