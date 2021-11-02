
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// lua
#include <luajit-2.0/lauxlib.h>
#include <luajit-2.0/lua.h>
#include <luajit-2.0/luajit.h>
#include <luajit-2.0/lualib.h>

#define LA_TMP_FILENAME "/tmp/la_tmp.lua"
lua_State *L;
bool reload = false;
bool error = false;

static int L_load_sample(lua_State *L);

// audio
#define MINIAUDIO_IMPLEMENTATION
#include "libs/miniaudio.h"

ma_device device;

//----------------------------------------------------------------------
void data_callback(ma_device *dev, void *out, const void *in,
                   ma_uint32 bufsize) {
  float *outbuf = (float *)out;

  lua_pushinteger(L, (double)bufsize);
  lua_setglobal(L, "la_bufsz");

  lua_getglobal(L, "la_run");
  if (lua_pcall(L, 0, 0, 0)) {
    if (!error) {
      printf("\n[lua error] %s\n", lua_tostring(L, lua_gettop(L)));
      lua_pop(L, lua_gettop(L));
      error = true;
    }
  } else {
    lua_getglobal(L, "la_buf");
    for (int i = 1; i <= bufsize; ++i) {
      lua_rawgeti(L, -1, (i - 1) * 2 + 1);
      lua_rawgeti(L, -2, (i - 1) * 2 + 2);

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

//----------------------------------------------------------------------
int init_lua() {
  printf("[lua] init lua...\n");

  L = luaL_newstate();
  luaL_openlibs(L);

  luaJIT_setmode(L, 0, LUAJIT_MODE_ENGINE | LUAJIT_MODE_ON);

  lua_pushcfunction(L, L_load_sample);
  lua_setglobal(L, "load_sample");

  luaL_dofile(L, "la.lua");

  lua_pushnumber(L, (double)device.sampleRate);
  lua_setglobal(L, "la_rate");

  lua_pushnumber(L, (double)1.0 / device.sampleRate);
  lua_setglobal(L, "la_inv_rate");

  lua_pushinteger(L, (double)device.playback.internalPeriodSizeInFrames);
  lua_setglobal(L, "la_bufsz");

  lua_getglobal(L, "la_buf");
  for (int i = 1; i <= device.playback.internalPeriodSizeInFrames * 2; i++) {
    lua_pushinteger(L, i % 2 == 0 ? -1 : 1);
    lua_rawseti(L, -2, i);
  }
  lua_setglobal(L, "la_buf");

  printf("[lua] init lua: successful\n");
  return 0;
}

//----------------------------------------------------------------------
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

//----------------------------------------------------------------------
static int L_load_sample(lua_State *L) {
  const char *filename = lua_tostring(L, 1);

  ma_decoder decoder;
  ma_result result = ma_decoder_init_file_flac(filename, NULL, &decoder);
  if (result != MA_SUCCESS) {
    printf("\n[audio] loading filename %s failed!\n", filename);
    return 0;
  }

  ma_uint32 chans = decoder.outputChannels;
  ma_uint64 dur = ma_decoder_get_length_in_pcm_frames(&decoder);
  ma_uint64 size = dur * chans;
  printf("\n[audio] loaded %s: dur %llu, chans %i\n", filename, dur, chans);

  float *data = (float *)malloc(size * sizeof(float));

  ma_decoder_read_pcm_frames(&decoder, data, size);
  ma_decoder_uninit(&decoder);

  lua_pushinteger(L, dur);
  lua_pushinteger(L, chans);

  lua_createtable(L, 0, 0);
  for (int i = 0; i < size; i++) {
    lua_pushnumber(L, data[i]);
    lua_rawseti(L, -2, i + 1);
  }

  return 3; // dur, chans, data
}

//----------------------------------------------------------------------
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

//----------------------------------------------------------------------
int cleanup() {
  // audio
  ma_device_stop(&device);
  ma_device_uninit(&device);

  // lua
  lua_close(L);

  return 0;
}

//----------------------------------------------------------------------
//----------------------------------------------------------------------
//----------------------------------------------------------------------
#define QUIT_KEYWORD "--quit"
#define RELOAD_KEYWORD "--reload"

int main(int argc, char **argv) {
  if (init_audio() || init_lua())
    return 1;

  ma_device_start(&device);

  printf("repl started, type --reload to reload, --quit to quit ...\n");

  char input_buffer[512];
  while (1) {
    printf("$ ");

    if (fgets(input_buffer, 512, stdin)) {
      if (strncmp(input_buffer, QUIT_KEYWORD, strlen(QUIT_KEYWORD)) == 0)
        break;
      else if (strncmp(input_buffer, RELOAD_KEYWORD, strlen(RELOAD_KEYWORD)) ==
               0) {
        print_command();
        reload = true;
      } else
        luaL_dostring(L, input_buffer);
    }
  }

  return cleanup();
}
