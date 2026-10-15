extends Node

signal interstitial_closed
signal rewarded_ad_completed
signal rewarded_ad_closed
signal ad_availability_changed

var provider: Node
var interstitial_ready := false
var rewarded_ready := false
var initialized := false

func initialize(admob_node: Node) -> void:
	provider = admob_node
	if provider == null or not Engine.has_singleton("AdmobPlugin"):
		return
	provider.consent_info_updated.connect(_on_consent_info_updated)
	provider.consent_info_update_failed.connect(_on_consent_info_update_failed)
	provider.consent_form_loaded.connect(_on_consent_form_loaded)
	provider.consent_form_dismissed.connect(_on_consent_form_dismissed)
	provider.consent_form_failed_to_load.connect(_on_consent_form_failed_to_load)
	provider.initialization_completed.connect(_on_initialization_completed)
	provider.interstitial_ad_loaded.connect(_on_interstitial_loaded)
	provider.interstitial_ad_failed_to_load.connect(_on_interstitial_failed_to_load)
	provider.interstitial_ad_dismissed_full_screen_content.connect(_on_interstitial_dismissed)
	provider.interstitial_ad_failed_to_show_full_screen_content.connect(_on_interstitial_failed_to_show)
	provider.rewarded_ad_loaded.connect(_on_rewarded_loaded)
	provider.rewarded_ad_failed_to_load.connect(_on_rewarded_failed_to_load)
	provider.rewarded_ad_dismissed_full_screen_content.connect(_on_rewarded_dismissed)
	provider.rewarded_ad_failed_to_show_full_screen_content.connect(_on_rewarded_failed_to_show)
	provider.rewarded_ad_user_earned_reward.connect(_on_rewarded_earned)
	# EEA consent is resolved before initializing the ads SDK or loading an ad.
	provider.update_consent_info()

func show_interstitial() -> bool:
	if not initialized or not interstitial_ready:
		return false
	interstitial_ready = false
	provider.show_interstitial_ad()
	return true

func show_rewarded() -> bool:
	if not initialized or not rewarded_ready:
		return false
	rewarded_ready = false
	ad_availability_changed.emit()
	provider.show_rewarded_ad()
	return true

func _consent_status() -> String:
	var consent = provider.get_consent_status()
	return consent.to_status_string() if consent != null else "UNKNOWN"

func _on_consent_info_updated() -> void:
	if _consent_status() == "REQUIRED":
		if provider.is_consent_form_available():
			provider.show_consent_form()
		else:
			provider.load_consent_form()
	elif _consent_status() == "NOT_REQUIRED" or _consent_status() == "OBTAINED":
		_initialize_sdk()

func _on_consent_info_update_failed(_error) -> void:
	# If consent cannot be confirmed, ads stay disabled for this session.
	push_warning("AdMob consent check failed; ads will remain disabled this session.")

func _on_consent_form_loaded() -> void:
	provider.show_consent_form()

func _on_consent_form_dismissed(_error) -> void:
	if _consent_status() != "REQUIRED":
		_initialize_sdk()

func _on_consent_form_failed_to_load(_error) -> void:
	# Do not request ads until a required consent form can be shown.
	push_warning("AdMob consent form could not be loaded; ads will remain disabled this session.")

func _initialize_sdk() -> void:
	if initialized:
		return
	provider.initialize()

func _on_initialization_completed(_status) -> void:
	initialized = true
	provider.load_interstitial_ad()
	provider.load_rewarded_ad()

func _on_interstitial_loaded(_ad_info, _response_info) -> void:
	interstitial_ready = true
	ad_availability_changed.emit()

func _on_interstitial_failed_to_load(_ad_info, _error) -> void:
	interstitial_ready = false
	ad_availability_changed.emit()

func _on_interstitial_dismissed(_ad_info) -> void:
	interstitial_ready = false
	provider.load_interstitial_ad()
	interstitial_closed.emit()

func _on_interstitial_failed_to_show(_ad_info, _error) -> void:
	interstitial_ready = false
	provider.load_interstitial_ad()
	interstitial_closed.emit()

func _on_rewarded_loaded(_ad_info, _response_info) -> void:
	rewarded_ready = true
	ad_availability_changed.emit()

func _on_rewarded_failed_to_load(_ad_info, _error) -> void:
	rewarded_ready = false
	ad_availability_changed.emit()

func _on_rewarded_dismissed(_ad_info) -> void:
	rewarded_ready = false
	provider.load_rewarded_ad()
	rewarded_ad_closed.emit()

func _on_rewarded_failed_to_show(_ad_info, _error) -> void:
	rewarded_ready = false
	provider.load_rewarded_ad()
	rewarded_ad_closed.emit()

func _on_rewarded_earned(_ad_info, _reward_data) -> void:
	rewarded_ad_completed.emit()
