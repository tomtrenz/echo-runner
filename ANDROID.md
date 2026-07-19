# Echo Runner pro Android

Android port používá stejné akce `InputMap` jako desktopová verze. Dotyková tlačítka proto pouze dodávají vstupy `left`, `right`, `jump` a `finish_loop`; fyzika runnera zůstává společná pro obě platformy.

## Ruční instalace APK

Hotový instalační soubor je v `build/android/echo-runner.apk`.

1. Přeneste APK do telefonu.
2. Otevřete soubor v telefonu.
3. Pokud se Android zeptá, povolte pro použitý správce souborů instalaci z neznámých zdrojů.
4. Potvrďte instalaci aplikace **Echo Runner**.

Přes USB debugging lze APK nainstalovat také z kořene projektu:

```bash
adb install -r build/android/echo-runner.apk
```

## Nové sestavení

Sestavení vyžaduje Godot 4.6.1 s Android export templates, JDK 17 nebo novější, Android SDK Platform 35 a Build Tools 35.0.1 nebo novější.

```bash
./build_android.sh
```

Skript nejprve ověří prostředí a spustí headless kontrolu projektu. Potom vytvoří podepsané debug APK. Pokud APK skutečně nevznikne, skript skončí chybou.

Volitelně lze nestandardní cesty nastavit proměnnými `GODOT_BIN`, `JAVA_HOME` a `ANDROID_HOME`.

## Ovládání

Desktop:

- doleva: `A` nebo šipka vlevo
- doprava: `D` nebo šipka vpravo
- skok: `W`, šipka nahoru nebo mezerník
- akce / předčasné dokončení kola: `E`

Android:

- vlevo dole: pohyb doleva a doprava
- vpravo dole: skok
- menší tlačítko **AKCE**: předčasné dokončení kola a vytvoření dalšího runnera

Dotykové ovládání se standardně zobrazuje jen na zařízení s touchscreenem. Pro test na desktopu vyberte instanci `MobileControls` ve scéně `game/game.tscn` a v Inspectoru zapněte exportovanou volbu **Show On Desktop**.

## Nastavení portu

- aplikace je uzamčená do landscape orientace
- interní rozlišení je 1280 × 720 se stretch režimem `canvas_items` a poměrem `expand`
- renderer používá GL Compatibility / OpenGL ES 3
- import mobilních textur má povolené ETC2/ASTC
- dotykové ovládání i hlavní HUD respektují display safe area
- na mobilu je level ukotvený vlevo nahoře a přizpůsobený tak, aby dole zůstal
  samostatný ovládací pruh a vpravo prostor pro HUD
- export obsahuje pouze ARM64 a neobsahuje editorový `addons/godot-git-plugin`
