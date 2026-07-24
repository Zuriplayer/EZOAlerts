# EZOAlerts Architecture

`EZOAlerts` separa productores, registro, persistencia, canales y salidas.

## Flujo

1. Un modulo productor, externo o interno, llama a una API publica: `ShowAlert`, `SendGroupAlert`, `RegisterAlert` o `TriggerAlert`.
2. `alert_registry.lua` resuelve definiciones y textos dinamicos.
3. `channels.lua` decide si un aviso va a pantalla, chat de grupo o ambos.
4. `renderer.lua` crea y actualiza el control visual.
5. `group_chat.lua` envia mensajes al chat de grupo.
6. `menu.lua` expone configuracion basica en LibAddonMenu.

Los productores internos viven bajo `modules/producers/`. Su trabajo es escuchar eventos del juego, traducirlos a contexto pequeno y disparar alertas registradas. No dibujan UI ni escriben directamente en chat.

Algunos productores pueden usar `EZOAlerts.Print` para mensajes locales privados cuando no deben salir al grupo. El caso de guilds compartidas en grupo vive ahi para evitar ruido en chat de grupo.

Los avisos de cofres y sacos pesados usan productores separados para que cada uno pueda tener su propia configuracion de pantalla, chat y enfriamiento.

El aviso de zona del lider usa mensajes locales y no viaja automaticamente. La accion de viajar queda fuera de EZOAlerts para poder resolverla en EZOTools.

La comprobacion de rol es local y no usa sets. Prioriza senales nativas simples: rol seleccionado, tipos de arma equipados y `abilityId` sloteados cuando la API los devuelve. Las alarmas cubren contradicciones claras; los warnings quedan como capa opcional para detalles menos definitivos. Puede silenciarse sin perder la configuracion cuando el rol distinto es intencionado. Sus avisos son persistentes hasta accion del jugador y permiten confirmar el caso o silenciar la sesion.

Los controles visuales propios deben registrarse como fragmentos de `HUD_SCENE` y `HUD_UI_SCENE`, y ademas mantener un guard interno para no mostrarse fuera de `hud` o `hudui`. `renderer.lua` es la ventana comun para avisos de pantalla. El toggle LAM de posicionamiento y la sesion compartida de disposicion de EZOCore usan el mismo `SetMoveMode`: al activarlo muestran la previsualizacion del aviso, permiten arrastrarla incluso en combate y mantienen el modo mover activo hasta que el control vuelva a desactivarse. Soltar el arrastre solo guarda la posicion; no apaga el modo mover. El combate no bloquea todos los avisos de pantalla: cada productor decide si su aviso debe usar `hideInCombat`.

El log es unico para todo el addon. Los productores registran entradas en `EZOAlerts_Log` solo mientras estamos en combate y el modulo hace un unico volcado a `LibDebugLogger`/`DebugLogViewer` al terminar combate. No usa el chat normal como fallback.

## Contratos

- Los productores no deben conocer controles UI.
- Los productores no deben llamar a `StartChatInput` directamente.
- Los productores internos deben poder apagarse desde SavedVariables/LAM si generan mensajes.
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
