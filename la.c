#include <luajit-2.0/lauxlib.h>
#include <luajit-2.0/lua.h>
#include <luajit-2.0/luajit.h>
#include <luajit-2.0/lualib.h>
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MINIAUDIO_IMPLEMENTATION
#include "libs/miniaudio.h"

// lua
#define LA_TMP_FILENAME "/tmp/la_tmp.lua"
lua_State *L;
bool reload = false;
bool error = false;
// ~lua

// audio
ma_device device;

typedef struct {
  float *data;
  ma_uint32 id, chans;
  ma_uint64 len, size;
} buffer;
buffer buffers[8];

int load_buffer(buffer *buf, char *filename);
float read_buffer(buffer *buf, ma_uint64 pos, ma_uint32 chan);
// ~audio

void data_callback(ma_device *dev, void *out, const void *in,
                   ma_uint32 bufsize) {
  float *outbuf = (float *)out;

  lua_pushinteger(L, (double)bufsize);
  lua_setglobal(L, "bufsz");

  lua_getglobal(L, "run_impl");
  if (lua_pcall(L, 0, 0, 0)) {
    if (!error) {
      printf("\n[lua error] %s\n", lua_tostring(L, lua_gettop(L)));
      lua_pop(L, lua_gettop(L));
      error = true;
    }
  } else {
    lua_getglobal(L, "buf");
    for (int i = 1; i <= bufsize; ++i) {
      lua_rawgeti(L, -1, i * 2 - 1);
      lua_rawgeti(L, -2, i * 2);
      outbuf[(i - 1) * 2 + 0] = lua_tonumber(L, -2);
      outbuf[(i - 1) * 2 + 1] = lua_tonumber(L, -1);
      lua_pop(L, 2);
    }
    lua_pop(L, 1);
  }

  if (reload) {
    luaL_dofile(L, LA_TMP_FILENAME);
    reload = false;
    error = false;
  }
}

int init_lua() {
  printf("[lua] init lua...\n");
  L = luaL_newstate();
  luaL_openlibs(L);

  luaJIT_setmode(L, 0, LUAJIT_MODE_ENGINE | LUAJIT_MODE_ON);

  lua_pushnumber(L, (double)device.sampleRate);
  lua_setglobal(L, "rate");

  lua_pushinteger(L, (double)device.playback.internalPeriodSizeInFrames);
  lua_setglobal(L, "bufsz");

  lua_createtable(L, 0, 0);
  for (int i = 1; i <= device.playback.internalPeriodSizeInFrames * 2; i++) {
    lua_pushinteger(L, i % 2 == 0 ? -1 : 1);
    lua_rawseti(L, -2, i);
  }
  lua_setglobal(L, "buf");

  luaL_dofile(L, "la.lua");

  printf("[lua] init lua: successful\n");
  return 0;
}

int init_audio() {
  printf("[audio] init audio...\n");
  ma_device_config config = ma_device_config_init(ma_device_type_playback);
  config.playback.format = ma_format_f32;
  config.playback.channels = 2;
  config.sampleRate = 0; // use default
  config.dataCallback = data_callback;

  if (ma_device_init(NULL, &config, &device) != MA_SUCCESS) {
    printf("[audio] init audio: failed!\n");
    return -1;
  }

  printf("[audio] init audio: successful!\n");
  return 0;
}

int load_buffer(buffer *buf, char *filename) {
  ma_decoder decoder;
  ma_result result = ma_decoder_init_file_flac(filename, NULL, &decoder);
  if (result != MA_SUCCESS) {
    printf("[audio] loading filename %s failed!\n", filename);
    return -1;
  }
  ma_uint64 len = ma_decoder_get_length_in_pcm_frames(&decoder);
  printf("[audio] loaded %s: chans %i, len %llu\n", filename,
         decoder.outputChannels, len);

  buf->len = len;
  buf->chans = decoder.outputChannels;
  buf->size = len * buf->chans;
  buf->data = (float *)malloc(buf->size * sizeof(float));

  ma_decoder_read_pcm_frames(&decoder, buf->data, buf->size);

  lua_createtable(L, 0, 0);
  for (int i = 0; i < buf->size; i++) {
    lua_pushnumber(L, buf->data[i]);
    lua_rawseti(L, -2, i + 1);
  }
  lua_setglobal(L, buf->id == 0 ? "test_sample" : "test_sample_2");

  lua_pushinteger(L, buf->size);
  lua_setglobal(L, buf->id == 0 ? "test_sample_size" : "test_sample_size_2");

  for (int i = 0; i < buf->size; ++i) {
    printf("i %i, f %f |", i, buf->data[i]);
  }
  printf("\n");

  ma_decoder_uninit(&decoder);
  return 0;
}

float read_buffer(buffer *buf, ma_uint64 pos, ma_uint32 chan) {
  if (chan < 0 || chan >= buf->chans || pos < 0 || pos >= buf->len ||
      !buf->data)
    return 0.0;

  return buf->data[pos * buf->chans + chan];
}

int init_samples() {
  buffers[0].id = 0;
  buffers[1].id = 1;
  load_buffer(&buffers[0], "test_sample.flac");
  load_buffer(&buffers[1], "test_sample_2.flac");
  return 0;
}

void print_command() {
  FILE *fp;
  if ((fp = fopen(LA_TMP_FILENAME, "r"))) {
    int c;
    while (1) {
      c = fgetc(fp);
      if (feof(fp))
        break;
      if (c == '\n')
        printf(" ");
      else if (c != '\t')
        printf("%c", c);
    }
    printf("\n");
    fclose(fp);
  }
}

void cleanup() {
  // audio
  for (int i = 0; i < 8; ++i)
    if (buffers[i].data)
      free(buffers[i].data);
  ma_device_uninit(&device);

  // lua
  lua_close(L);
}

int main(int argc, char **argv) {

  if (init_audio() || init_lua())
    return 1;

  init_samples();
  ma_device_start(&device);

  printf("repl started, press enter to reload...\n");
  char input_buffer[512];
  while (1) {
    printf("#");
    if (!fgets(input_buffer, 512, stdin))
      break;
    else {
      reload = true;
      print_command();
    }
  }

  return 0;
}
