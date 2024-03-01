PLAYER_W = 100
PLAYER_H = 80
SPEED = 12
FPS = 60

def spawn_pokemons(args)
  size = 64
  initial_y = rand(args.grid.h - size * 2) + size
  {
    # x: rand(args.grid.w) + size,
    x: args.grid.w + size,
    # y: rand(args.grid.h - size * 2) + size,
    # y: (rand(args.grid.h * 0.4) + args.grid.h * 0.6),
    y: initial_y, # between things
    w: size * 1.5,
    h: size * 1.5,
    path: "sprites/pokemon/spr_e_#{random_formatted_number}_1.png",
  }
end

def random_formatted_number
  number = ((rand() * 25) + 1).round
  number.to_s.rjust(3, '0')
end

def fire_input?(args)
  args.inputs.keyboard.key_down.z || args.inputs.keyboard.key_down.j || args.inputs.controller_one.key_down.a
end

def tick(args)
  # if args.state.tick_count == 1
  #   args.audio[:music] = { input: "sounds/flight.ogg", looping: true }
  # end

  render_background(args)

  args.state.player ||= {
    x: (args.grid.w / 2) - PLAYER_W,
    y: 40,
    w: PLAYER_W,
    h: PLAYER_H,
    speed: SPEED,
  }

  player_sprite_index = 0.frame_index(count: 6, hold_for: 8, repeat: true)
  args.state.player.path = "sprites/misc/dragon-#{player_sprite_index}.png"
  args.state.fireballs ||= []
  args.state.pokemons ||= [
    spawn_pokemons(args),
  ]
  args.state.score ||= 0
  args.state.timer ||= 30 * FPS

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
  spit_fire(args)
  # move_targets(args)
  move_pokemons(args)
  remove_hit_objects(args)

  args.outputs.sprites << [
    args.state.background,
    args.state.player,
    args.state.fireballs,
    args.state.targets,
    args.state.pokemons,
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

  if args.state.timer <- 30 && fire_input?(args)
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

# def move_targets(args)
#   args.state.targets.each do |target|
#     target.x -= args.state.player.speed / 2
#     # if (target.y == target.initial_y) # || (target.y > (target.initial_y - 200))
#     #   target.y -= args.state.player.speed / 6
#     #   puts "start"
#     # elsif target.y >= (target.initial_y - 200)
#     #   puts "#{target.y} is greater than #{target.initial_y - 200}"
#     #   target.y -= args.state.player.speed / 6
#     # elsif target.y <= (target.initial_y + 200)
#     #   puts "how often"
#     #   target.y += args.state.player.speed / 2
#     #   puts "#{target.y} is less than #{target.initial_y + 200}"
#     # end

#     # 185 is greater than 183
#     # >> 185 == 183
#     # 183 is greater than 183

#     # if target.just_init == true
#     #   target.y -= args.state.player.speed / 2
#     #   puts "target.y: #{target.y}"
#     #   puts "target.initial_y: #{target.initial_y}"
#     #   puts "if #{target.y} is greater than #{target.initial_y - 200}"
#     #   puts "if #{target.y} is less than #{target.initial_y - 200}"
#     # end
#     # if target.y <= (target.initial_y - 200)
#     #   target.just_init = false
#     #   puts "hitting it? &"
#     #   target.y += args.state.player.speed / 6
#     # end
#     # if (target.y <= (target.initial_y - 200)) && (target.just_init == false)
#     #   puts "test"
#     #   target.y += args.state.player.speed / 6
#     # end
#     # if (target.y >= (target.initial_y + 200)) && (target.just_init == false)
#     #   puts "test this"
#     # end
#     # if target
#     # #   target.just_init = false
#     # # elsif target.y <= (target.initial_y - 200).to_i
#     #   puts "minus"
#     #   target.y += args.state.player.speed / 6
#     # elsif target.y >= (target.initial_y + 200).to_i
#     #   puts "plus"
#     #   target.y -= args.state.player.speed / 3
#     # end

#     # y = 200
#     # upper_bound = 250 (initial.y + 50)
#     # lower_bound = 150 (initial.y - 50)
#     # if start
#       # go down
#     # if hit lower_bound
#       # go up
#     # if hit upper_bound
#       # go downe
#     # end

#     # if y = 200
#     #   y -= 20
#     #   (y = 180, y = 160, y = 140, y = 120, y = 100, y = 80, y = 60, y = 40, y = 20)
#     # elsif y <= (200 - 160 = 40)
#     #   y += 20
#     #   (y = 60, y = 80, y = 100, y = 120, y = 140, y = 160, y = 180, y = 200, y = 220, y = 240)
#     # elsif y >= 240
#     #   y -= 20
#     # end

#     # if target.y < (target.initial_y - 50)
#     #   target.y += args.state.player.speed / 4
#     #   puts "up"
#     # elsif (target.y > target.initial_y + 50) || (target.y == target.initial_y)
#     #   target.y -= args.state.player.speed / 4
#     #   puts "down"
#     # end

#     # direction = "down"
#     # interval = 30
#     # args.state.move ||= args.state.tick_count
#     # if args.state.move % 30 == 0
#     #   if direction == "down"
#     #     target.y += args.state.player.speed / 4
#     #     direction = "up"
#     #   elsif direction == "up"
#     #     target.y -= args.state.player.speed / 4
#     #     direction = "down"
#     #   end
#     #   # args.state.move = args.state.tick_count + interval
#     # end

#     if target.x < 0
#       target.dead = true
#     end
#   end
# end


def move_pokemons(args)
  args.state.pokemons.each do |pokemon|
    pokemon.x -= args.state.player.speed / 2
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

def spit_fire(args)
  if fire_input?(args)
    args.outputs.sounds << "sounds/fireball.wav"
    args.state.fireballs << {
      x: args.state.player.x + args.state.player.w,
      y: args.state.player.y + (args.state.player.h/6),
      w: 32,
      h: 32,
      path: 'sprites/misc/fireball.png',
    }
  end

  args.state.fireballs.each do |fireball|
    fireball.y += args.state.player.speed + 2

    if fireball.y > args.grid.h
      fireball.dead = true
      next
    end

    args.state.pokemons.each do |pokemon|
      if args.geometry.intersect_rect?(pokemon, fireball)
        args.outputs.sounds << "sounds/target.wav"
        pokemon.dead = true
        fireball.dead = true
        args.state.score += 1
      end
    end
  end
end

def remove_hit_objects(args)
  args.state.pokemons.reject! { |p| p.dead}
  args.state.fireballs.reject! { |f| f.dead }
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
    path: 'sprites/background/background_plains-Sheet1.png'
  }
  scroll_point_at = args.state.tick_count
  scroll_point_at ||= 0

  args.outputs.sprites << scrolling_background(scroll_point_at, 'sprites/background/background_plains-sheet2.png', 0.25)
  args.outputs.sprites << scrolling_background(scroll_point_at, 'sprites/background/background_plains-sheet3.png', 0.5)
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