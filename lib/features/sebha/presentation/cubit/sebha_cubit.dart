import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../azkar/domain/usecases/get_azkar.dart';
import '../../domain/entities/sebha_entity.dart';
import '../../domain/usecases/get_sebha_data.dart';
import '../../domain/usecases/reset_sebha_counter.dart';
import '../../domain/usecases/save_sebha_data.dart';
import 'sebha_state.dart';

class SebhaCubit extends Cubit<SebhaState> {
  final GetSebhaData getSebhaData;
  final SaveSebhaData saveSebhaData;
  final ResetSebhaCounter resetSebhaCounter;
  final GetAzkar getAzkar;

  static const List<String> defaultAzkar = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'أستغفر الله',
    'لا حول ولا قوة إلا بالله',
  ];

  SebhaCubit({
    required this.getSebhaData,
    required this.saveSebhaData,
    required this.resetSebhaCounter,
    required this.getAzkar,
  }) : super(const SebhaState());

  Future<void> loadSebhaData() async {
    emit(state.copyWith(status: SebhaStatus.loading));

    try {
      final data = getSebhaData();
      final allAzkar = await getAzkar();

      final customAzkar = allAzkar
          .where((zekr) => zekr.isCustom)
          .map((zekr) => zekr.text)
          .where((text) => text.trim().isNotEmpty)
          .toSet()
          .toList();

      final loadedState = SebhaState.fromEntity(data);

      emit(
        loadedState.copyWith(
          status: SebhaStatus.success,
          customAzkar: customAzkar,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SebhaStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> increment() async {
    if (state.isCompleted) return;

    emit(
      state.copyWith(
        status: SebhaStatus.success,
        count: state.count + 1,
        clearError: true,
      ),
    );

    await _saveCurrentData();
  }

  Future<void> resetCounter() async {
    emit(
      state.copyWith(
        status: SebhaStatus.success,
        count: 0,
        clearError: true,
      ),
    );

    try {
      await resetSebhaCounter();
    } catch (e) {
      emit(
        state.copyWith(
          status: SebhaStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> changeZikr(String zikr) async {
    if (state.zikr == zikr) return;

    emit(
      state.copyWith(
        status: SebhaStatus.success,
        zikr: zikr,
        count: 0,
        clearError: true,
      ),
    );

    await _saveCurrentData();
  }

  Future<void> changeTarget(int target) async {
    if (state.target == target) return;

    emit(
      state.copyWith(
        status: SebhaStatus.success,
        target: target,
        count: 0,
        clearError: true,
      ),
    );

    await _saveCurrentData();
  }

  Future<void> _saveCurrentData() async {
    try {
      await saveSebhaData(
        SebhaEntity(
          count: state.count,
          target: state.target,
          zikr: state.zikr,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SebhaStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}