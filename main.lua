-- TODO: better separation of data and logic.
-- local MODE = "static"
local MODE = "dynamic"
local nathan={}
local world, mouse_collisions -- the "World" object and a collection of objects colliding with the mouse
local mouse_joint, clicked_ud
local bounceables = {} -- generic single sprite phsyics objects with sounds

-- "Shallow" table copy; non-recursive
local function cpy(t)
  local c = {}
  for k,v in pairs(t) do
    c[k] = v
  end
  return c
end

-- Create a generic draggable bouncing rectangle with image and sound assets
local function create_bounceable(img_path, click_paths, release_paths, x, y, restitution)
  restitution = restitution or 0.9
  x = x or 0
  y = y or 0

  local image
  if type(img_path) == "string" then
    image = love.graphics.newImage("assets/" .. img_path)
  else
    assert(type(img_path) == "table" and #img_path == 3, "Bounceable image path must be a string or an RGB color table.")
    image = img_path
  end

  local click_sounds = {}
  for _,v in ipairs(click_paths) do
    assert(type(v) == 'string', "Bounceable sound path must be string")
    click_sounds[#click_sounds+1] = love.audio.newSource("assets/" .. v, "static")
  end
  local release_sounds = {}
  for _,v in ipairs(release_paths) do
    assert(type(v) == 'string', "Bounceable sound path must be string")
    release_sounds[#release_sounds+1] = love.audio.newSource("assets/" .. v, "static")
  end
  local body = love.physics.newBody(world, x, y, MODE)
  local shape = love.physics.newRectangleShape(0, 0, image:getWidth(), image:getHeight())
  local fixture = love.physics.newFixture(body, shape, 1)
  fixture:setRestitution(restitution)

  local data_table = {
    clickable = true,
    image = image,
    sounds = {
      click = click_sounds,
      release = release_sounds
    }
  }
  fixture:setUserData(data_table)
  bounceables[#bounceables+1] = fixture -- fixture is all we need to store to retrieve other data
end

local function load_bounceables()
  create_bounceable("sansa.png", {"brup.wav"}, {"breeow.wav"}, 400, 400, 1.2)
  create_bounceable("ernie.png", {"hiss.wav"}, {"rasp.wav"}, 60, 60)
end

local function draw_bounceables()
  for _,b in ipairs(bounceables) do
    local ud = b:getUserData()
    local body = b:getBody()
    if type(ud.image) == "table" then
      -- fill a rectangle according to the RGB triplet
      love.graphics.setColor(unpack(ud.image))
      love.graphics.polygon("fill", body:getWorldPoints(b:getShape():getPoints()))
    else
      love.graphics.draw(ud.image,
                         body:getX(),
                         body:getY(),
                         body:getAngle(),
                         1,1,
                         ud.image:getWidth()/2,
                         ud.image:getHeight()/2)
    end
  end
end

local function load_nathan()
  nathan.sounds = {}
  nathan.sounds.click = {}
  nathan.sounds.release = {}
  nathan.sounds.click[1] = love.audio.newSource("assets/hey-chelsea.wav", "static")
  nathan.sounds.release[1] = love.audio.newSource("assets/i-love-you.wav", "static")

  local clickable = { -- user data table for all clickable objects
    clickable = true,
    sounds = nathan.sounds
  }

  nathan.images = {}
  nathan.images.head = love.graphics.newImage "assets/nhead.png"
  nathan.images.body = love.graphics.newImage "assets/nbody.png"
  nathan.images.leg = love.graphics.newImage "assets/nleg.png"
  nathan.images.arm = love.graphics.newImage "assets/narm.png"

  nathan.head = {}
    nathan.head.body = love.physics.newBody(world, 650/2, 650/2, MODE)
    nathan.head.shape = love.physics.newCircleShape(36) --the ball's shape has a radius of 20
    nathan.head.fixture = love.physics.newFixture(nathan.head.body, nathan.head.shape, 1)
    nathan.head.fixture:setRestitution(0.9) --let the ball bounce
    nathan.head.fixture:setUserData(cpy(clickable))

  nathan.bod = {}
    nathan.bod.body = love.physics.newBody(world, 650/2+20, 650/2+40+70, MODE)
    nathan.bod.shape = love.physics.newRectangleShape(0,0, 60, 140)
    nathan.bod.fixture = love.physics.newFixture(nathan.bod.body, nathan.bod.shape, 1)
    nathan.bod.fixture:setRestitution(0.9)
    nathan.bod.fixture:setUserData(cpy(clickable))
  love.physics.newRevoluteJoint(nathan.head.body, nathan.bod.body, 650/2+20, 650/2+40, true)

  nathan.rarm = {}
    nathan.rarm.body = love.physics.newBody(world, 650/2+50+35, 650/2+40+30, MODE)
    nathan.rarm.shape = love.physics.newRectangleShape(0,0, 70, 20)
    nathan.rarm.fixture = love.physics.newFixture(nathan.rarm.body, nathan.rarm.shape, 1)
    nathan.rarm.fixture:setRestitution(0.9)
    nathan.rarm.fixture:setUserData(cpy(clickable))
  love.physics.newRevoluteJoint(nathan.bod.body, nathan.rarm.body, 650/2+50, 650/2+40+30, false)

  nathan.larm = {}
    nathan.larm.body = love.physics.newBody(world, 650/2+20-65, 650/2+40+30, MODE)
    nathan.larm.shape = love.physics.newRectangleShape(0,0, 70, 20)
    nathan.larm.fixture = love.physics.newFixture(nathan.larm.body, nathan.larm.shape, 1)
    nathan.larm.fixture:setRestitution(0.9)
    nathan.larm.fixture:setUserData(cpy(clickable))
  love.physics.newRevoluteJoint(nathan.bod.body, nathan.larm.body, 650/2-10, 650/2+40+30, false)

  local xo = 15
  local yo = 20
  nathan.rleg = {}
    nathan.rleg.body = love.physics.newBody(world, 650/2+20-xo, 650/2+180+yo, MODE)
    nathan.rleg.shape = love.physics.newRectangleShape(0,0, 20, 70)
    nathan.rleg.fixture = love.physics.newFixture(nathan.rleg.body, nathan.rleg.shape, 1)
    nathan.rleg.fixture:setRestitution(0.9)
    nathan.rleg.fixture:setUserData(cpy(clickable))
  love.physics.newRevoluteJoint(nathan.bod.body, nathan.rleg.body, 650/2+20-xo, 650/2+145+yo, false)

  nathan.lleg = {}
    nathan.lleg.body = love.physics.newBody(world, 650/2+20+xo, 650/2+180+yo, MODE)
    nathan.lleg.shape = love.physics.newRectangleShape(0,0, 20, 70)
    nathan.lleg.fixture = love.physics.newFixture(nathan.lleg.body, nathan.lleg.shape, 1)
    nathan.lleg.fixture:setRestitution(0.9)
    nathan.lleg.fixture:setUserData(cpy(clickable))
  love.physics.newRevoluteJoint(nathan.bod.body, nathan.lleg.body, 650/2+20+xo, 650/2+145+yo, false)
end

local function draw_nathan()
  -- local origin_offset = nathan.head.shape:getRadius()
  love.graphics.draw(nathan.images.head, 
                     nathan.head.body:getX(), 
                     nathan.head.body:getY(), 
                     nathan.head.body:getAngle(),
                     1, 1, -- scale factor
                     nathan.images.head:getWidth()/2,
                     nathan.images.head:getHeight()/2)
  love.graphics.draw(nathan.images.body,
                     nathan.bod.body:getX(), 
                     nathan.bod.body:getY(), 
                     nathan.bod.body:getAngle(),
                     1, 1, -- scale factor
                     nathan.images.body:getWidth()/2,
                     nathan.images.body:getHeight()/2)

  local half_arm_width = nathan.images.arm:getWidth()/2
  local half_arm_height = nathan.images.arm:getHeight()/2
  love.graphics.draw(nathan.images.arm,
                     nathan.larm.body:getX(), 
                     nathan.larm.body:getY(), 
                     nathan.larm.body:getAngle(),
                     -1, 1, -- scale factor
                     half_arm_width, half_arm_height)
  love.graphics.draw(nathan.images.arm,
                     nathan.rarm.body:getX(), 
                     nathan.rarm.body:getY(), 
                     nathan.rarm.body:getAngle(),
                     1, 1, -- scale factor
                     half_arm_width, half_arm_height)

  local half_leg_width = nathan.images.leg:getWidth()/2
  local half_leg_height = nathan.images.leg:getHeight()/2
  love.graphics.draw(nathan.images.leg,
                     nathan.lleg.body:getX(), 
                     nathan.lleg.body:getY(), 
                     nathan.lleg.body:getAngle(),
                     1, 1, -- scale factor
                     half_leg_width, half_leg_height)
  love.graphics.draw(nathan.images.leg,
                     nathan.rleg.body:getX(), 
                     nathan.rleg.body:getY(), 
                     nathan.rleg.body:getAngle(),
                     1, 1, -- scale factor
                     half_leg_width, half_leg_height)
end

function love.load()
  math.randomseed(os.time())
  love.physics.setMeter(64) --the height of a meter our worlds will be 64px
  world = love.physics.newWorld(0, 9.81*64, true)

  mouse_collisions = {}

  load_nathan()
  load_bounceables()

  objects = {} -- table to hold all our physical objects

  --let's create the ground
  local ground_width = 50
  objects.ground = {}
    objects.ground.body = love.physics.newBody(world, 400, 700-ground_width/2)
    objects.ground.shape = love.physics.newRectangleShape(800, ground_width)
    objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape);
  objects.ceil = {}
    objects.ceil.body = love.physics.newBody(world, 400, ground_width/2)
    objects.ceil.shape = love.physics.newRectangleShape(800, ground_width)
    objects.ceil.fixture = love.physics.newFixture(objects.ceil.body, objects.ceil.shape);
  objects.lwall = {}
    objects.lwall.body = love.physics.newBody(world, ground_width/2, 350)
    objects.lwall.shape = love.physics.newRectangleShape(ground_width, 700-ground_width)
    objects.lwall.fixture = love.physics.newFixture(objects.lwall.body, objects.lwall.shape);
  objects.rwall = {}
    objects.rwall.body = love.physics.newBody(world, 800-ground_width/2, 350)
    objects.rwall.shape = love.physics.newRectangleShape(ground_width, 700-ground_width)
    objects.rwall.fixture = love.physics.newFixture(objects.rwall.body, objects.rwall.shape);

  --let's create a couple blocks to play around with
  objects.block1 = {}
    objects.block1.body = love.physics.newBody(world, 200, 550, "dynamic")
    objects.block1.shape = love.physics.newRectangleShape(0, 0, 50, 100)
    objects.block1.fixture = love.physics.newFixture(objects.block1.body, objects.block1.shape, 5)

  objects.block2 = {}
    objects.block2.body = love.physics.newBody(world, 200, 400, "dynamic")
    objects.block2.shape = love.physics.newRectangleShape(0, 0, 100, 50)
    objects.block2.fixture = love.physics.newFixture(objects.block2.body, objects.block2.shape, 2)

  objects.mouse = {}
    objects.mouse.body = love.physics.newBody(world, 0, 0, "kinematic")
    objects.mouse.shape = love.physics.newRectangleShape(0, 0, 5, 5)
    objects.mouse.fixture = love.physics.newFixture(objects.mouse.body, objects.mouse.shape, 1)
    objects.mouse.fixture:setSensor(true) -- prevent collisions


  --[================================================================[
     Here we set up callbacks for start and end of mouse collision.
     The LOVE documentation is wrong. The typical order of events is:
    
     1. Collision Start callback is triggered.
     2. While object is colliding, the pre-solve callback is
        continuously triggered. This is where a collision can
        be disabled.
     3. Collision post-solve is triggered, unless the collision
        was previously disabled in the pre-solve callback.
     4. Collision end callback is triggered when bodies are
        no longer in contact.
  --]================================================================]
  local beginContact = function(a, b, coll)
    local object = (a == objects.mouse.fixture and b) 
                or (b == objects.mouse.fixture and a) 
                or false
    if not object then return end
    local ud = object:getUserData()
    if ud and ud.clickable then
      mouse_collisions[ud] = object
    end
  end

  local endContact = function(a, b, coll)
    local ud
    if a == objects.mouse.fixture then
      ud = b:getUserData()
    elseif b == objects.mouse.fixture then
      ud = a:getUserData()
    else 
      return 
    end

    if ud and mouse_collisions[ud] then
      mouse_collisions[ud] = nil
    end
  end

  world:setCallbacks(beginContact, endContact, nil, nil)

  --initial graphics setup
  love.graphics.setBackgroundColor(104, 136, 248) --set the background color to a nice blue
  love.graphics.setColorMode('replace')
end

function love.mousepressed(x, y, button)
  if button ~= "l" then return end
  for ud,v in pairs(mouse_collisions) do
    clicked_ud = ud
    mouse_joint = love.physics.newMouseJoint(v:getBody(), x, y)
    if ud.sounds then
      local randy = math.random(#ud.sounds.click)
      love.audio.play(ud.sounds.click[randy])
    end
    return
  end
end

function love.mousereleased(x, y, button)
  if button ~= "l" then return end
  if mouse_joint then 
    if clicked_ud.sounds then
      local randy = math.random(#clicked_ud.sounds.release)
      love.audio.play(clicked_ud.sounds.release[randy])
    end
    mouse_joint:destroy()
    mouse_joint = nil; clicked_ud = nil
  end
end

function love.update(dt)
  -- update mouse stuff
  objects.mouse.body:setPosition(love.mouse.getPosition())
  if mouse_joint then 
    mouse_joint:setTarget(love.mouse.getPosition())
  end
  world:update(dt)
end

function love.draw()
  love.graphics.setColor(72, 160, 14)
  love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))
  love.graphics.polygon("fill", objects.lwall.body:getWorldPoints(objects.lwall.shape:getPoints()))
  love.graphics.polygon("fill", objects.rwall.body:getWorldPoints(objects.rwall.shape:getPoints()))
  love.graphics.polygon("fill", objects.ceil.body:getWorldPoints(objects.ceil.shape:getPoints()))

  draw_nathan()
  draw_bounceables()

  love.graphics.setColor(50, 50, 50) -- set the drawing color to grey for the blocks
  love.graphics.polygon("fill", objects.block1.body:getWorldPoints(objects.block1.shape:getPoints()))
  love.graphics.polygon("fill", objects.block2.body:getWorldPoints(objects.block2.shape:getPoints()))
end
