[English](../README.md) · [简体中文](../docs/README.zh-Hans.md) · [繁體中文](../docs/README.zh-Hant.md) · [日本語](../docs/README.ja.md) · [한국어](../docs/README.ko.md) · [Deutsch](../docs/README.de.md) · [Français](../docs/README.fr.md) · [Español](../docs/README.es.md)

# Eingabesync · InputSync

Synchronisiert die Eingabequelle eines entfernten Macs mit dem lokalen Mac über Apples Bildschirmfreigabe. **Nur auf dem lokalen Mac installieren.** Auf dem entfernten Mac sind weder eine App noch SSH nötig.

![InputSync-Demo – simulierte Oberfläche, keine Bildschirmaufnahme](assets/inputsync-demo.gif)

## Einstieg

1. Die neueste `.dmg` aus den [GitHub Releases](https://github.com/94cp/InputSync/releases/latest) dieses Projekts herunterladen und öffnen. **InputSync** nach **Applications (Programme)** ziehen und anschließend von dort starten. Xcode und eigenes Kompilieren sind nicht nötig.
2. Über den Berechtigungseintrag der App den Zugriff erlauben. Je nach macOS heißt die Kategorie Bedienungshilfen oder sinngemäß Gerätesteuerung und Datenzugriff.
3. Mit Apples Bildschirmfreigabe zum entfernten Mac verbinden.
4. Die Synchronisierung der Tastatursprache in InputSync aktivieren. Dies geht auch im Menü „Bearbeiten“ der lokalen Bildschirmfreigabe.
5. Die Synchronisierung in InputSync aktivieren, die lokale Eingabequelle wechseln und vor der Eingabe etwa eine Sekunde warten.

Die App startet immer pausiert, auch bei der Anmeldung. Während der Synchronisierung kann kurz ein Menü auf dem entfernten Mac erscheinen.

### Erster Start wird blockiert

Diese Version ist nicht mit einer Apple Developer ID signiert und nicht notarisiert. macOS meldet möglicherweise, dass der Entwickler oder die App nicht auf Schadsoftware überprüft werden kann.

Wenn du die App aus den [GitHub Releases](https://github.com/94cp/InputSync/releases/latest) dieses Projekts geladen hast:

1. InputSync einmal aus **Programme** öffnen. Bei einer Blockierung die Meldung schließen, ohne die App in den Papierkorb zu legen.
2. **Systemeinstellungen → Datenschutz & Sicherheit** öffnen und zu **Sicherheit** scrollen.
3. Bei der Meldung zu InputSync auf **Dennoch öffnen** klicken.
4. Falls verlangt, mit Mac-Anmeldepasswort oder Touch ID bestätigen und anschließend **Öffnen** wählen.

Fehlt die Schaltfläche, die App erneut öffnen und zu den Einstellungen zurückkehren. Nach dem Start erscheint InputSync in der Menüleiste, ohne Hauptfenster. Danach die angeforderte Berechtigung für Bedienungshilfen erteilen; sie ist von der Erlaubnis zum Öffnen getrennt.

## Funktionsweise

Die Tastatursprachensynchronisierung der Bildschirmfreigabe aktualisiert manchmal nur die Anzeige auf dem entfernten Mac, während die aktive App den bisherigen Eingabemodus behält. In unseren Tests wurde der Wechsel durch kurzes Öffnen und Schließen eines entfernten Menüs wirksam. InputSync automatisiert diesen Ablauf.

1. macOS-Mitteilungen über Änderungen der lokalen Eingabequelle beobachten, unabhängig von Taste oder Tastenkürzel.
2. Die eingestellte Verzögerung abwarten (standardmäßig 0,5 Sekunden), damit die Bildschirmfreigabe zuerst die Sprache synchronisiert.
3. Über die Bedienungshilfen die Position des freigegebenen Bildschirms ermitteln, oben links in dessen Menüleiste klicken und das Menü mit Escape schließen.

Dies ist eine experimentell geprüfte Umgehung über die Oberfläche, keine direkte Ansteuerung einer entfernten Eingabemethoden-API. Die entfernte Menüleiste muss an der erwarteten Stelle erreichbar sein. Ein kurzes Aufblenden des Menüs gehört zum Verfahren.

Fenster lassen sich verschieben und skalieren. Änderungen während einer ausstehenden Aktualisierung überspringen diese; danach die Eingabequelle erneut wechseln. Nicht alle Vollbild- und Skalierungskombinationen sind getestet.

## Symbol und Sprache

Unter „Mehr“ das Menüleistensymbol wählen. „Automatisch“ nutzt erkennbare Tastaturlayouts, sonst die Systemregion:

- Festlandchina, Taiwan, Hongkong, Macau: **中/英**
- Japan: **英数 / かな**
- Südkorea: **한/영**
- Andere Regionen: Globus

Dies ist ein Vorschlag, keine Erkennung der Tastenbeschriftung. Manuelle Auswahl hat Vorrang. Tastenbelegung und Eingabequelle bleiben unverändert.

Die App folgt der in macOS unter Sprache & Region festgelegten App-Sprache. Acht Sprachen sind enthalten; sonst wird Englisch verwendet.

## Hilfe

- **Zugriff erlaubt, aber nicht verfügbar:** Berechtigung dieser App aus- und einschalten, dann die App neu starten. Nach Updates kann eine erneute Freigabe nötig sein.
- **Keine Synchronisierung:** Optionen in beiden Apps prüfen, das entfernte Fenster aktiv halten oder die Verzögerung erhöhen.
- **Protokoll:** Über „Mehr“ öffnen.

Mit ABC und systemeigenem vereinfachtem Pinyin unter macOS 27.2 geprüft. Andere Eingabemethoden und ältere Systeme sind nicht vollständig getestet. Für Apples Bildschirmfreigabe; kein bestimmtes Mac-Modell oder feste Fenstergröße erforderlich.

## Entfernen

Anmeldestart deaktivieren, App beenden und löschen. Optional das Protokoll löschen: `~/Library/Logs/InputSync/events.log`.

## Entwicklung unterstützen

Wenn InputSync dir hilft, spendier mir gerne einen Kaffee. Auch ein Star auf GitHub freut mich!

| WeChat Pay | Alipay |
| :---: | :---: |
| <img src="assets/donate/wechat.png" alt="WeChat Pay" width="180"> | <img src="assets/donate/alipay.png" alt="Alipay" width="180"> |

[Entwicklung](DEVELOPMENT.md)
