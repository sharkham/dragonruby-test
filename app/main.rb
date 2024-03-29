PLAYER_W = 200
PLAYER_H = 160
SPEED = 10
FPS = 60

def spawn_pokemons(args)
  size = 64
  initial_y = rand(args.grid.h - size * 2) + size
  {
    x: args.grid.w + size,
    y: initial_y,
    w: size * 1.5,
    h: size * 1.5,
    path: "sprites/pokemon/flying/spr_e_#{random_formatted_number}_1.png",
    y_line: rand(args.grid.h - size * 2) + size,
    wiggle_speed: (rand() * 100) + 90,
    x_speed: (SPEED / 1.5 + (rand() * 6) - 2).round,
  }
end

def random_formatted_number
  number = ((rand() * 69) + 1).round
  number.to_s.rjust(3, '0')
end

def throw_input?(args)
  args.inputs.keyboard.key_down.z || args.inputs.keyboard.key_down.j || args.inputs.controller_one.key_down.a
end

def tick args
  if args.state.tick_count == 1
    args.audio[:music] = { input: "sounds/main_game_theme.ogg", gain: 0.25, looping: true }
  end

  args.state.scene ||= "title"

  send("#{args.state.scene}_tick", args)
end

def title_tick(args)
  if throw_input?(args)
    args.outputs.sounds << 'sounds/game-over.wav'
    args.state.scene = "gameplay"
    return
  end

  render_background(args)

  labels = []
  labels << {
    x: args.grid.center_x,
    y: args.grid.h - 100,
    text: "Safari Zone",
    size_enum: 20,
    alignment_enum: 1,
  }
  labels << {
    x: args.grid.center_x,
    y: args.grid.h - 175,
    text: "Catch the Pokémon!",
    alignment_enum: 1,
  }
  labels << {
    x: args.grid.center_x,
    y: args.grid.h - 230,
    text: "By Sam",
    alignment_enum: 1,
  }
  labels << {
    x: args.grid.center_x,
    y: args.grid.h - 280,
    text: "Arrow or WASD to move | Z or J (or A on gamepad) to throw",
    alignment_enum: 1,
  }
  labels << {
    x: args.grid.center_x,
    y: 175,
    text: "Throw to start",
    size_enum: 5,
    alignment_enum: 1,
  }
  args.outputs.labels << labels
end

def gameplay_tick(args)
  # if args.state.tick_count == 1
  #   args.audio[:music] = { input: "sounds/flight.ogg", looping: true }
  # end

  render_background(args)

  args.state.player ||= {
    x: (args.grid.w / 2) - PLAYER_W,
    y: 0,
    w: PLAYER_W,
    h: PLAYER_H,
    speed: SPEED,
  }

  # player_sprite_index = 0.frame_index(count: 6, hold_for: 8, repeat: true)
  # args.state.player.path = "sprites/misc/dragon-#{player_sprite_index}.png"
  args.state.player.path = "sprites/pokemon/may4.png"
  args.state.pokeballs ||= []
  args.state.pokemons ||= [
    spawn_pokemons(args),
  ]
  args.state.score ||= 0
  args.state.timer ||= 15 * FPS

  args.state.timer -= 1

  if args.state.timer == 0
    args.audio[:music].paused = true
    args.outputs.sounds << "sounds/game-over.wav"
  end

  # args.state.timer
  #   args.state.targets << spawn_target(args)
  # end


  if args.state.timer < 0
    game_over_tick(args)
    return
  end

  summon_pokemons(args)
  handle_player_movement(args)
  throw_pokeball(args)
  # move_targets(args)
  move_pokemons(args)
  remove_hit_objects(args)

  args.outputs.sprites << [
    args.state.background,
    args.state.pokeballs,
    args.state.targets,
    args.state.pokemons,
    args.state.player,
  ]

  labels = []
  labels << {
    x: 40,
    y: args.grid.h - 40,
    text: "Score: #{args.state.score}",
    size_enum: 4,
  }
  labels << {
    x: args.grid.w - 40,
    y: args.grid.h - 40,
    text: "Time left: #{(args.state.timer / FPS).round}",
    size_enum: 2,
    alignment_enum: 2,
  }
  args.outputs.labels << labels
end

HIGH_SCORE_FILE = "high-score.txt"
def game_over_tick(args)
  args.state.high_score ||= args.gtk.read_file(HIGH_SCORE_FILE).to_i

  args.state.timer -= 1

  if !args.state.saved_high_score.to_i && args.state.score > args.state.high_score.to_i
    args.gtk.write_file(HIGH_SCORE_FILE, args.state.score.to_s)
    args.state.saved_high_score = true
  end

  labels = []
  labels << {
    x: 40,
    y: args.grid.h - 40,
    text: "Game Over!",
    size_enum: 10,
  }
  labels << {
    x: 40,
    y: args.grid.h - 90,
    text: "Score: #{args.state.score}",
    size_enum: 4,
  }
  labels << {
    x: 40,
    y: args.grid.h - 132,
    text: "Fire to restart",
    size_enum: 2,
  }

  if args.state.timer < -10 && throw_input?(args)
    $gtk.reset
  end

  if args.state.score.to_i > args.state.high_score.to_i
    labels << {
      x: 260,
      y: args.grid.h - 90,
      text: "New high-score!",
      size_enum: 3,
    }
  else
    labels << {
      x: 260,
      y: args.grid.h - 90,
      text: "Score to beat: #{args.state.high_score}",
      size_enum: 3,
    }
  end

  args.outputs.labels << labels
end

def move_pokemons(args)
  args.state.pokemons.each do |pokemon|
    pokemon.x -= pokemon.x_speed # args.state.player.speed +
    phase = (args.tick_count / pokemon.wiggle_speed) * Math::PI * 2
    y_off = Math.sin(phase) * 70

    pokemon.y = pokemon.y_line + y_off
    if pokemon.x < 0
      pokemon.dead = true
    end
  end
end

def summon_pokemons(args)
  interval = 30
  args.state.next_time ||= args.state.tick_count + interval
  if args.state.next_time.elapsed?
    args.state.pokemons << spawn_pokemons(args)
    args.state.next_time = args.state.tick_count + interval
  end
end

def throw_pokeball(args)
  if throw_input?(args)
    args.outputs.sounds << "sounds/throw.wav"
    args.state.pokeballs << {
      x: args.state.player.x + args.state.player.w,
      y: args.state.player.y + (args.state.player.h/6),
      w: 32,
      h: 32,
      path: 'sprites/pokemon/i_old_poke-ball.png',
      angle: args.state.tick_count * 2,
    }
  end

  args.state.pokeballs.each do |fireball|
    fireball.y += args.state.player.speed - 3
    fireball.x += args.state.player.speed / 1.25

    if (fireball.y > args.grid.h) || (fireball.x > args.grid.w)
      fireball.dead = true
      args.state.pokemons << spawn_pokemons(args)
      next
    end

    args.state.pokemons.each do |pokemon|
      if args.geometry.intersect_rect?(pokemon, fireball)
        args.outputs.sounds << "sounds/catch.wav"
        pokemon.dead = true
        fireball.dead = true
        args.state.score += 1
      end
    end
  end
end

def remove_hit_objects(args)
  args.state.pokemons.reject! { |p| p.dead}
  args.state.pokeballs.reject! { |f| f.dead }
end

def handle_player_movement(args)
  if args.inputs.left
    args.state.player.x -= args.state.player.speed
  elsif args.inputs.right
    args.state.player.x += args.state.player.speed
  end

  if args.state.player.x +  args.state.player.w > args.grid.w
    args.state.player.x = args.grid.w - args.state.player.w
  end

  if args.state.player.x < 0
    args.state.player.x = 0
  end
end

def render_background(args)
  args.outputs.sprites << {
    x: 0,
    y: 0,
    w: 1280,
    h: 720,
    path: 'sprites/background/background_valley-sheet1.png'
  }
  scroll_point_at = args.state.tick_count
  scroll_point_at ||= 0

  args.outputs.sprites << scrolling_background(scroll_point_at, 'sprites/background/background_plains-sheet2.png', 0.25)
  args.outputs.sprites << scrolling_background(scroll_point_at, 'sprites/background/background_valley-sheet3.png', 0.5)
  args.outputs.sprites << scrolling_background(scroll_point_at, 'sprites/background/background_plains-sheet4.png', 1)
  args.outputs.sprites << scrolling_background(scroll_point_at, 'sprites/background/background_plains-sheet5.png', 1.5)
end

def scrolling_background(at, path, rate, y = 0)
  [
    { x: 0 - at.*(rate) % 1440, y: y, w: 1440, h: 720, path: path },
    { x: 1440 - at.*(rate) % 1440, y: y, w: 1440, h: 720, path: path }
  ]
end

$gtk.reset