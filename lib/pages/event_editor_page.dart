import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../auth/auth_controller.dart';
import '../config/api_config.dart';
import '../config/event_types.dart';
import '../data/event_api_store.dart';
import '../theme/app_colors.dart';
import '../widgets/app_buttons.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/glamora_brand_assets.dart';
import '../widgets/responsive_container.dart';
import '../widgets/soft_card.dart';
import 'event_hub_page.dart';

class EventEditorPage extends StatefulWidget {
  const EventEditorPage({super.key, this.eventId});

  /// When null, creates a new event.
  final String? eventId;

  @override
  State<EventEditorPage> createState() => _EventEditorPageState();
}

class _EventEditorPageState extends State<EventEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _venue = TextEditingController();
  final _description = TextEditingController();
  DateTime? _startsAt;
  var _moderation = true;
  var _loading = false;
  String? _eventType;

  @override
  void initState() {
    super.initState();
    final email = authController.host?.email;
    if (widget.eventId != null && email != null) {
      final e = eventApiStore.event(email, widget.eventId!);
      if (e != null) {
        _title.text = e.title;
        _venue.text = e.venue ?? '';
        _description.text = e.description;
        _startsAt = e.startsAt;
        _moderation = e.moderationEnabled;
        _eventType = e.eventType;
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _venue.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startsAt ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _startsAt = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final email = authController.host?.email;
    if (email == null) return;

    setState(() => _loading = true);

    try {
      if (widget.eventId == null) {
        final e = await eventApiStore.createEvent(
          title: _title.text,
          startsAt: _startsAt,
          venue: _venue.text,
          eventType: _eventType,
          description: _description.text,
          moderationEnabled: _moderation,
        );
        if (!mounted) return;
        setState(() => _loading = false);
        if (e == null) return;
        Navigator.of(context).pushReplacement<void, void>(
          MaterialPageRoute<void>(
            builder: (_) => EventHubPage(
              ownerEmail: email,
              eventId: e.id,
              initialTab: 3,
            ),
          ),
        );
        return;
      }

      await eventApiStore.updateEventPatch(widget.eventId!, {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'moderationEnabled': _moderation,
        'venue': _venue.text.trim().isEmpty ? null : _venue.text.trim(),
        'eventType': _eventType,
        'startsAt': _startsAt?.toIso8601String(),
      });

      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.of(context).pop();
    } on ApiConnectionException {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 10),
          content: Text(
            'Cannot reach the API at ${ApiConfig.baseUrl}.\n\n'
            '1) Open this in Chrome: ${ApiConfig.baseUrl}/health\n'
            '   If it does not load, start the server:\n'
            '   cd ~/Documents/event_camshot_backend && npm start\n'
            '   (leave that terminal open)\n\n'
            '2) Or run both together: npm run dev:app\n\n'
            '3) In the Flutter terminal press R (hot restart).',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.eventId != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: GlamoraAppBarTitle(title: isEdit ? 'Edit event' : 'New event'),
      ),
      body: ResponsiveContainer(
        maxWidth: 560,
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: SoftCard(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEdit ? 'Update details' : 'Event details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Guests will see the title and date on the upload page. You can change moderation anytime.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    AuthTextField(
                      controller: _title,
                      label: 'Event title',
                      hint: 'Jordan & Alex — Summer Celebration',
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if ((v ?? '').trim().length < 3) return 'Enter a title';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Event type',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Scroll sideways to choose a category.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: kEventTypeOptions.length,
                        separatorBuilder: (_, index) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final type = kEventTypeOptions[i];
                          final selected = _eventType == type;
                          return ChoiceChip(
                            label: Text(type),
                            selected: selected,
                            showCheckmark: false,
                            onSelected: (_) => setState(() => _eventType = type),
                          );
                        },
                      ),
                    ),
                    if (_eventType != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _loading ? null : () => setState(() => _eventType = null),
                          child: const Text('Clear type'),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.event_rounded),
                        label: Text(
                          _startsAt == null
                              ? 'Pick event date (optional)'
                              : 'Event date: ${_startsAt!.year}-${_startsAt!.month.toString().padLeft(2, '0')}-${_startsAt!.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                    if (_startsAt != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => setState(() => _startsAt = null),
                          child: const Text('Clear date'),
                        ),
                      ),
                    AuthTextField(
                      controller: _venue,
                      label: 'Venue (optional)',
                      hint: 'Rosewood Estate',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _description,
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Welcome message (optional)',
                        hintText: 'Thank you for celebrating with us—share your favorite moments!',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile.adaptive(
                      value: _moderation,
                      onChanged: _loading ? null : (v) => setState(() => _moderation = v),
                      title: const Text('Require approval before photos appear'),
                      subtitle: const Text(
                        'When on, new guest uploads land in Review first.',
                        style: TextStyle(fontSize: 13),
                      ),
                      activeThumbColor: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    PrimaryAppButton(
                      label: _loading
                          ? 'Saving…'
                          : isEdit
                              ? 'Save changes'
                              : 'Create event',
                      icon: isEdit ? Icons.save_rounded : Icons.check_rounded,
                      onPressed: _loading ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
