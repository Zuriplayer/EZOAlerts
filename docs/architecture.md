# EZOAlerts Architecture

`EZOAlerts` separa productores, registro, persistencia, canales y salidas.

## Flujo

1. Un modulo productor llama a una API publica: `ShowAlert`, `SendGroupAlert`, `RegisterAlert` o `TriggerAlert`.
2. `alert_registry.lua` resuelve definiciones y textos dinamicos.
3. `channels.lua` decide si un aviso va a pantalla, chat de grupo o ambos.
4. `renderer.lua` crea y actualiza el control visual.
5. `group_chat.lua` envia mensajes al chat de grupo.
6. `menu.lua` expone configuracion basica en LibAddonMenu.

## Contratos

- Los productores no deben conocer controles UI.
- Los productores no deben llamar a `StartChatInput` directamente.
- El renderer no debe decidir reglas de negocio.
- El modulo de chat no debe decidir reglas de eventos.
- Las SavedVariables deben vivir en `saved_vars.lua`.
- La localizacion debe vivir en `lang/en.lua` y `lang/es.lua`.

## Canales

- `screen`: aviso visual en pantalla.
- `groupChat`: mensaje al chat de grupo.

Por defecto, los avisos registrados sin `channels` van solo a pantalla.

Ejemplo:

```lua
EZOAlerts.RegisterAlert("ready_check", {
    kind = EZOAlerts.ALERT_KIND_INFO,
    channels = {
        screen = true,
        groupChat = true,
    },
    screenText = "Ready check",
    groupText = "Ready check started.",
})
```

## Kinds

- `info`
- `warning`
- `error`

Estos valores deben permanecer simples porque luego pueden mapearse a estilos de `EZOTools`.
