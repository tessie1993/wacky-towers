## CanvasLayer indices for the UI stack (ADR-0016 §2). Higher draws on top.
class_name UiLayers
extends RefCounted

const HUD: int = 10
const SCREENS: int = 20
const PAUSE: int = 30
const DIALOGS: int = 40
const TOASTS: int = 50
const COVER: int = 60
