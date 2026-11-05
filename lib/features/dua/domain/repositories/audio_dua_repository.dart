
import '../entities/audio_dua_entity.dart';

abstract class AudioDuaRepository {
  Future<List<AudioDuaEntity>> getAudioDuas();

  Future<List<String>> getFavoriteAudioDuaIds();

  Future<void> toggleFavorite(String duaId);
}
