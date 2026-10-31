import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/azkar_entity.dart';
import '../../domain/usecases/get_azkar.dart';
import '../../domain/usecases/add_custom_azkar.dart';
import '../../domain/usecases/update_custom_azkar.dart';
import '../../domain/usecases/delete_custom_azkar.dart';
import 'azkar_state.dart';

class AzkarCubit extends Cubit<AzkarState> {
  final GetAzkar getAzkar;
  final AddCustomAzkar addCustomAzkar;
  final UpdateCustomAzkar updateCustomAzkar;
  final DeleteCustomAzkar deleteCustomAzkar;

  AzkarCubit({
    required this.getAzkar,
    required this.addCustomAzkar,
    required this.updateCustomAzkar,
    required this.deleteCustomAzkar,
  }) : super(const AzkarState());

  Future<void> loadAzkar() async {
    emit(state.copyWith(status: AzkarStatus.loading));

    try {
      final azkar = await getAzkar();

      emit(
        state.copyWith(
          status: AzkarStatus.success,
          azkar: azkar,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AzkarStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      debugPrint('LOAD AZKAR ERROR: $e');

    }
  }

  Future<void> addCustomZikr(AzkarEntity azkar) async {
    try {
      await addCustomAzkar(azkar);
      await _refreshAzkar();
    } catch (e) {
      _emitFailure(e);
    }
  }

  Future<void> updateCustomZikr(AzkarEntity azkar) async {
    try {
      await updateCustomAzkar(azkar);
      await _refreshAzkar();
    } catch (e) {
      _emitFailure(e);
    }
  }

  Future<void> deleteCustomZikr(int id) async {
    try {
      await deleteCustomAzkar(id);
      await _refreshAzkar();
    } catch (e) {
      _emitFailure(e);
    }
  }

  Future<void> _refreshAzkar() async {
    final azkar = await getAzkar();

    emit(
      state.copyWith(
        status: AzkarStatus.success,
        azkar: azkar,
      ),
    );
  }

  void _emitFailure(Object error) {
    debugPrint('AZKAR ERROR: $error');

    emit(
      state.copyWith(
        status: AzkarStatus.failure,
        errorMessage: error.toString(),
      ),
    );
  }
}