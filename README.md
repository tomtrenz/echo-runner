# Echo Runner

Echo Runner je 2D strategická plošinovka vytvořená v Godot 4.6. Hráč má na každý průchod levelem omezený čas. Po skončení kola se jeho vstupy uloží, level se obnoví a vznikne echo, které předchozí pohyb přesně zopakuje. Hráč tak spolupracuje se svými minulými verzemi a postupně řeší hádanky s tlačítky, dveřmi, nepřáteli a cílem.

## Spuštění

1. Otevřete projekt v Godot 4.6 nebo novějším.
2. Spusťte celý projekt klávesou `F5`.

Hlavní scéna projektu je `game/game.tscn`.

## Ovládání

- pohyb doleva: `A` nebo šipka doleva
- pohyb doprava: `D` nebo šipka doprava
- skok: `W`, mezerník nebo šipka nahoru
- předčasně dokončit kolo a vytvořit echo: `E`

## Herní systém

- Každý level určuje délku kola a maximální počet ech.
- `LoopManager` zaznamenává vstup hráče po fyzikálních snímcích.
- Po skončení kola se celý level znovu vytvoří ze své `PackedScene`.
- Klávesou `E` lze kolo dokončit okamžitě; zbývající čas nahrávky se doplní nečinností, takže echo zůstane stát na místě.
- Dokončené nahrávky zůstávají mezi koly stejného levelu.
- Při přechodu do dalšího levelu se staré nahrávky smažou.
- Echo používá stejnou scénu runnera a stejné fyzikální reakce jako živý hráč.
- Echo může reagovat na nepřátele a aktivovat tlačítka, ale nemění hráčovo skóre ani HUD zdraví.
- Sebraný collectible patří nahrávce runnera, který ho získal. Dokud je tato nahrávka ve frontě ech, předmět zůstává skrytý.
- Když stará nahrávka vypadne z FIFO fronty, její předměty se vrátí a jejich nepotvrzené body se odečtou.
- Po dosažení cíle se aktivní body potvrdí a globální skóre pokračuje do dalšího levelu.

## Programátorská část

Projekt je rozdělený na malé scény a třídy s jednou hlavní odpovědností. Herní objekty spolu komunikují převážně pomocí signálů, takže například tlačítko nemusí znát konkrétní implementaci dveří a level nemusí obsahovat speciální skript pro každou hádanku.

### Hlavní konstrukty Godotu a GDScriptu

- `class_name` vytváří pojmenované typy jako `Runner`, `LoopManager`, `BaseLevel`, `PressurePlate` a `EchoDoor`.
- `@export` zpřístupňuje návrhářské parametry v Inspectoru. Level tak nastavuje například `max_echoes` a `loop_duration_seconds`, aniž by se měnil zdrojový kód.
- `@onready` načítá reference na uzly až po vstupu scény do stromu.
- Godot signály oddělují odesílatele události od příjemce, například `pressed_changed`, `loop_finished`, `completed` nebo `score_changed`.
- `PackedScene.instantiate()` vytváří levely, živého runnera i echa ze sdílených scén.
- `RefCounted` je použit pro malé datové objekty bez uzlu ve stromu: `RunnerInput` a `LoopRecording`.
- Typované proměnné a kolekce, například `Array[LoopRecording]`, omezují nechtěné kombinování různých datových typů.
- `await` se používá při bezpečném odstranění levelu a při krátkém přechodu mezi levely.

### Rozdělení odpovědností

| Část | Odpovědnost |
| --- | --- |
| `Game` | Načítání kampaně, přechody mezi levely, vytvoření živého runnera a propojení hlavních systémů. |
| `BaseLevel` | Společné rozhraní levelu, spawn body, parametry kola, cíl a collectible objekty. |
| `LoopManager` | Čas kola, záznam vstupu, FIFO fronta nahrávek, vytvoření a přehrávání ech. |
| `Runner` | Fyzika, pohyb, skok, zdraví, knockback, animace a konfigurace echa. |
| `RunnerInput` | Jeden příkazový snímek: směr pohybu a informace o stisku skoku. |
| `LoopRecording` | Posloupnost příkazových snímků a předměty sebrané během daného průchodu. |
| `ScoreManager` | Aktivní body současného levelu a potvrzené globální skóre kampaně. |
| `LoopHUD` | Zobrazení stavu; neřídí herní logiku. |

### Oddělení vstupu od fyziky runnera

Klávesnice ani dotyková tlačítka nemění fyziku postavy přímo. `Runner.read_human_input()` převede aktuální `InputMap` stav na objekt `RunnerInput`. Metoda `Runner.apply_input(input_frame, delta)` potom provede pohyb podle dodaného příkazu a sama žádné `Input.*` nečte.

```gdscript
func read_human_input() -> RunnerInput:
    var input_frame := RunnerInput.new()
    input_frame.direction = Input.get_axis("left", "right")
    input_frame.jump_pressed = Input.is_action_just_pressed("jump")
    return input_frame
```

Díky tomu lze do stejné fyzikální metody poslat živý vstup hráče nebo dříve zaznamenaný vstup echa. Desktopové klávesy a Android `TouchScreenButton` používají stejné akce `left`, `right`, `jump` a `finish_loop`.

### Záznam kola a přehrávání echa

`LoopManager` pracuje ve fyzikálních snímcích, nikoli podle proměnlivého času renderování. V každém `_physics_process()`:

1. načte příkaz živého runnera,
2. uloží jej do `current_recording.input_frames`,
3. pošle odpovídající starší příkaz každému echu,
4. aplikuje aktuální příkaz živému runnerovi,
5. zvýší `current_tick`.

Po skončení kola se `current_recording` přesune do `completed_recordings`. Pokud počet záznamů překročí `max_echoes`, nejstarší záznam se odstraní pomocí `pop_front()`. Jde tedy o FIFO frontu. Při stisku akce `E` nebo mobilního tlačítka **AKCE** se chybějící snímky doplní neutrálním `RunnerInput`, a proto dokončené echo po posledním pohybu stojí.

Echo vzniká ze stejné `runner.tscn` jako hráč. `configure_as_echo()` pouze vypne lidský vstup, změní skupinu, průhlednost a kolizní vrstvy. Pohyb, gravitace, zdraví i reakce na nepřítele zůstávají společné.

### Reset levelu

Reset není implementován ručním vracením každého nepřítele, dveří nebo tlačítka. `Game` odstraní aktuální instanci levelu z `LevelContainer` a vytvoří novou instanci stejné `PackedScene`. Tím se celé prostředí vrátí do výchozího stavu.

`LoopManager` je mimo `LevelContainer`, takže reset přežije a zachová dokončené nahrávky. Při přechodu do dalšího levelu se naopak zavolá `reset_recordings()`, protože echa patří pouze k levelu, ve kterém vznikla.

### Příklad: dvě tlačítka a dvě dveře v levelu 3

Level 3 obsahuje čtyři samostatné instance v uzlu `Interactables`:

```text
Interactables
├── PlateA
├── DoorA
├── PlateB
└── DoorB
```

`PressurePlate` vysílá signál:

```gdscript
signal pressed_changed(is_pressed: bool)
```

`EchoDoor` poskytuje metodu se stejným logickým parametrem:

```gdscript
func set_open(new_value: bool) -> void:
    is_open = new_value
    collision_shape.set_deferred("disabled", is_open)
    closed_visual.visible = not is_open
    open_visual.visible = is_open
```

Konkrétní párování je deklarované přímo v `levels/level_03.tscn`:

```ini
[connection signal="pressed_changed"
    from="Interactables/PlateA"
    to="Interactables/DoorA"
    method="set_open"]

[connection signal="pressed_changed"
    from="Interactables/PlateB"
    to="Interactables/DoorB"
    method="set_open"]
```

Výsledek je jednoznačný:

| Tlačítko | Ovládané dveře |
| --- | --- |
| `PlateA` | `DoorA` |
| `PlateB` | `DoorB` |

Hodnota `is_pressed` ze signálu se automaticky předá jako argument `new_value` metodě dveří. Stisknutí `PlateA` proto neovlivní `DoorB` a naopak. Stejným způsobem lze v editoru přidat další dvojice bez úpravy skriptů.

Tlačítko navíc neukládá pouze jeden stav `true/false`, ale slovník `_runner_ids` s ID všech runnerů, kteří na něm stojí. Když jeden runner odejde, tlačítko zůstane aktivní, pokud na něm stále stojí hráč nebo jiné echo. Tlačítko přijímá skupinu `runner`, zatímco cíl přijímá pouze skupinu `player`; echo tedy může držet tlačítko, ale nemůže samo dokončit level.

### Collectible objekty a globální skóre

Každý collectible má stabilní `collectible_id` a počet bodů. Sebrání zapisuje do `LoopRecording.collected_items`, takže body patří konkrétní nahrávce. `LoopManager.get_active_collectibles()` skládá stav všech nahrávek, které jsou právě ve FIFO frontě.

Když nejstarší echo z fronty vypadne, jeho nepotvrzené předměty přestanou být aktivní, ve znovu vytvořené scéně se objeví a aktivní skóre se přepočítá. Po dosažení cíle `ScoreManager.commit_level_score()` přesune aktivní body do `banked_score`, který zůstává zachovaný mezi levely.

### Skupiny a kolizní vrstvy

- skupina `runner`: živý hráč i echa; používají ji tlačítka a nepřátelé,
- skupina `player`: pouze živý hráč; používá ji cíl levelu,
- fyzikální vrstvy oddělují prostředí, hráče, echa a nepřátele,
- echo nekoliduje s hráčem ani s ostatními echy, ale zachovává kolize s prostředím a interakci s `Area2D` tlačítky.

## Struktura projektu

```text
game/
├── game.tscn
└── game.gd

levels/
├── base_level.tscn
├── base_level.gd
├── level_01.tscn
├── level_02.tscn
├── level_03.tscn
├── level_04.tscn
└── level_05.tscn

actors/runner/
├── runner.tscn
├── runner.gd
└── runner_input.gd

systems/
├── loop_manager.gd
├── loop_recording.gd
└── score_manager.gd

objects/
├── pressure_plate.tscn
├── echo_door.tscn
├── level_goal.tscn
├── potvora.tscn
└── mince.tscn

tilesets/
├── platform_tileset.tres
└── background_tileset.tres
```

## Struktura levelu

Každý level dědí z `levels/base_level.tscn` a zachovává společné schéma:

```text
Level
├── BackgroundColor
├── TileMapBackground
├── TileMapWorld
├── TileMapWorldHalf
├── DecorationsFront
├── RunnerSpawn
├── EchoSpawn
├── Actors
├── Interactables
├── Collectibles
└── Goal
```

- `TileMapWorld` obsahuje pevné prostředí a kolize.
- `TileMapWorldHalf` používá stejný 32×32 tileset, ale je posunutý o 16 px dolů pro plošiny na polovině mřížky.
- `TileMapBackground` a `DecorationsFront` jsou dekorativní vrstvy bez kolizí.
- `Actors` obsahuje živého runnera, echa a nepřátele.
- `Interactables` obsahuje tlačítka, dveře a další logické objekty.
- `Collectibles` obsahuje mince a další bodované předměty. Jejich název uzlu slouží jako stabilní ID v rámci levelu.
- `RunnerSpawn` a `EchoSpawn` určují počáteční pozice.

HUD zobrazuje potvrzené a aktivní skóre ve formátu `Skóre: 100 (+20)`. Část v závorce patří současnému runnerovi a aktivním nahrávkám ech.

Rozmístění dlaždic je uložené samostatně v každém levelu. Definice dlaždic a jejich kolize jsou sdílené prostřednictvím souborů v adresáři `tilesets/`.

## Kampaň

- Level 1: první echo a jedno tlačítko.
- Level 2: delší cesta a spolupráce s jedním echem.
- Level 3: dvě tlačítka a dvě echa.
- Level 4: echo v kombinaci s nepřítelem.
- Level 5: tři tlačítka, tři echa a finální hádanka.

## Použité zdroje

Grafické zdroje SpriteLib jsou uložené v `spritelib_gpl/`; původní licenční informace jsou v `spritelib_gpl/license.txt`. Další zdroje projektu budou popsány v kořenovém souboru `resources.md`.
