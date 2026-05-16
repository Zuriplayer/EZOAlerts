# EZOAlerts

Addon independiente de la familia EZO para avisos en pantalla y mensajes controlados al chat de grupo.

El objetivo es desarrollar el sistema de avisos como pieza modular y pequena, con una superficie facil de integrar en `EZOTools` si en el futuro conviene consolidarlo.

## Filosofia

- Interfaz unica en LibAddonMenu.
- Sin keybindings.
- Sin menues laterales.
- Sin interceptar input.
- Dos idiomas: ingles y espanol, con modo automatico.
- Runtime organizado por responsabilidades.
- API pequena para productores de avisos.
- Canales separados: pantalla y chat de grupo.

## API prevista

```lua
EZOAlerts.ShowAlert("Texto", EZOAlerts.ALERT_KIND_INFO)
EZOAlerts.SendGroupAlert("Texto para el grupo")

EZOAlerts.RegisterAlert("example", {
    kind = EZOAlerts.ALERT_KIND_WARNING,
    channels = {
        screen = true,
        groupChat = true,
    },
    text = function(context)
        return context and context.message or "Alert"
    end,
    groupText = function(context)
        return context and context.groupMessage or "Group alert"
    end,
})

EZOAlerts.TriggerAlert("example", { message = "Ready" })
```

## Estructura

- `EZOAlerts.lua`: inicializacion.
- `modules/core.lua`: constantes publicas.
- `modules/saved_vars.lua`: defaults y SavedVariables.
- `modules/i18n.lua`: aplicacion de idiomas.
- `modules/alert_registry.lua`: registro y API de avisos.
- `modules/channels.lua`: dispatcher de canales.
- `modules/renderer.lua`: renderer visual en pantalla.
- `modules/group_chat.lua`: salida controlada al chat de grupo.
- `modules/menu.lua`: panel LAM.
- `docs/architecture.md`: decisiones tecnicas.
- `docs/integration-with-ezotools.md`: plan de integracion futura.
