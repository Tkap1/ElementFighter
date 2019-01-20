# A script for managing the health of an entity
extends Node

signal death
signal hit

var maxHealth = 0
var currentHealth = 0
var invulnerable = false
var dead = false
var healthBar = null

func _init(maxHealth):
    self.maxHealth = maxHealth
    self.currentHealth = maxHealth
    
func takeDamage(damage):
    # If damage is negative (heal)
    if damage < 0:
        # Heal the entity
        currentHealth -= damage
        
        # Don't let the current health go above the maximum health
        currentHealth = min(currentHealth, maxHealth)
        
        # Update health bar
        if healthBar != null:
            updateHealthBar()
        
        
    # Else if the damage is positive and we are not invulnerable
    elif damage > 0 and not invulnerable:
        # Take the damage
        currentHealth -= damage
        # Update health bar
        if healthBar != null:
            updateHealthBar()
        emit_signal("hit")
        # If current health is less than 0, set the dead flag to true
        if currentHealth <= 0:
            emit_signal("death")
            dead = true

# Add a health bar
func addHealthbar(parent, offset, size):
    healthBar = Refs.scripts.healthBar.new(parent, offset, size)
    add_child(healthBar)
    
# Update the health bar
func updateHealthBar():
    var percent = float(currentHealth) / maxHealth
    healthBar.setPercent(percent)
            
            
# Makes the entity invulnerable for a duration
func setInvulnerable(duration):
    invulnerable = true
    # Create a timer, add it as a child of this script, and connect it to the "cancelInvulnerable" function
    Utils.addTimer(self, duration, true, true, self, "cancelInvulnerable", [], true)
    
# Cancels the invulnerability state of the entity and frees the timer
func cancelInvulnerable(timer):
    invulnerable = false
    # Free the timer
    timer.queue_free()
    
    
