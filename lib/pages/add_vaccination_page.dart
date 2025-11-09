import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/vaccine_model.dart';
import '../services/vaccine_service.dart';
import '../themes/themes.dart';

class AddVaccinationDialog extends StatefulWidget {
  final String petName;
  final String petId;
  final Vaccination? existingVaccine; // If provided, we're editing
  const AddVaccinationDialog({
    super.key,
    required this.petName,
    required this.petId,
    this.existingVaccine,
  });

  @override
  State<AddVaccinationDialog> createState() => _AddVaccinationDialogState();
}

class _AddVaccinationDialogState extends State<AddVaccinationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineNameCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();

  DateTime? _dateGiven;
  DateTime? _nextDueDate;
  bool _submitting = false;

  final _svc = VaccineService();

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if editing
    if (widget.existingVaccine != null) {
      final v = widget.existingVaccine!;
      _vaccineNameCtrl.text = v.name;
      _dateGiven = v.date;
      _nextDueDate = v.nextDueDate;
      _batchCtrl.text = v.batchNumber ?? '';
    }
  }

  @override
  void dispose() {
    _vaccineNameCtrl.dispose();
    _batchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isGiven}) async {
    final now = DateTime.now();
    final initial = isGiven ? (_dateGiven ?? now) : (_nextDueDate ?? now.add(const Duration(days: 365)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) {
      setState(() {
        if (isGiven) {
          _dateGiven = picked;
        } else {
          _nextDueDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateGiven == null || _nextDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both dates')));
      return;
    }
    setState(() => _submitting = true);
    
    final bool ok;
    if (widget.existingVaccine != null) {
      // Update existing vaccine
      ok = await _svc.updateVaccinationForUserPetId(
        petId: widget.petId,
        vaccineId: widget.existingVaccine!.id,
        vaccineName: _vaccineNameCtrl.text.trim(),
        dateGiven: _dateGiven!,
        nextDueDate: _nextDueDate!,
        veterinarian: widget.existingVaccine!.veterinarian,
        batchNumber: _batchCtrl.text.trim().isEmpty ? null : _batchCtrl.text.trim(),
      );
    } else {
      // Add new vaccine
      ok = await _svc.addVaccinationForUserPetId(
        petId: widget.petId,
        petName: widget.petName,
        vaccineName: _vaccineNameCtrl.text.trim(),
        dateGiven: _dateGiven!,
        nextDueDate: _nextDueDate!,
        veterinarian: 'Mobile App',
        batchNumber: _batchCtrl.text.trim().isEmpty ? null : _batchCtrl.text.trim(),
      );
    }
    
    setState(() => _submitting = false);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.existingVaccine != null ? 'Vaccination updated' : 'Vaccination saved')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.existingVaccine != null ? 'Failed to update vaccination' : 'Failed to save vaccination')),
      );
    }
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: secondaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String hint,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date == null ? hint : DateFormat('MMM dd, yyyy').format(date),
                style: TextStyle(
                  fontSize: 14,
                  color: date == null ? Colors.grey[600] : Colors.black,
                  fontWeight: date == null ? FontWeight.w400 : FontWeight.normal,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.vaccines, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.existingVaccine != null ? 'Edit Vaccine Record' : 'Add Vaccine Record',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.petName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStyledTextField(
                        controller: _vaccineNameCtrl,
                        hint: 'Vaccine Name',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        hint: 'Date Given',
                        date: _dateGiven,
                        onTap: () => _pickDate(isGiven: true),
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        hint: 'Next Due Date',
                        date: _nextDueDate,
                        onTap: () => _pickDate(isGiven: false),
                      ),
                      const SizedBox(height: 16),
                      _buildStyledTextField(
                        controller: _batchCtrl,
                        hint: 'Batch Number (optional)',
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.existingVaccine != null ? 'Update Vaccination' : 'Save Vaccination',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
