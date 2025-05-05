import os
import json
import subprocess
import sys
import logging
from pathlib import Path
from typing import Dict, Any, Optional, List
import time
"""
Project Zomboid Mod Manager
A tool for managing mods, items, recipes, models, and sounds for Project Zomboid.
"""

# Constants
# Path to the registry file that stores mod information
REGISTRY_FILE = os.path.join("core", "modmanager_registry.json")
# Path to the log file for error tracking
LOG_FILE = os.path.join("log", "modmanager.log")

# Platform-specific script paths
SCRIPT_PATHS = {
    'windows': {
        'install_mod': os.path.join('core', 'Windows', 'mod', 'install_mod.bat'),
        'create_item': os.path.join('core', 'Windows', 'create_item.bat'),
        'create_mod': os.path.join('core', 'Windows', 'mod', 'create_mod.bat'),
        'mod_manager_help': os.path.join('core', 'Windows', 'mod_manager_help.bat'),
        'create_recipe': os.path.join('core', 'Windows', 'create_recipe.bat'),
        'create_model': os.path.join('core', 'Windows', 'create_model.bat'),
        'create_sound': os.path.join('core', 'Windows', 'create_sound.bat')
    },
    'unix': {
        'install_mod': os.path.join('core', 'Linux', 'mod', 'install_mod.sh'),
        'create_mod': os.path.join('core', 'Linux', 'mod', 'create_mod.sh'),
        'create_item': os.path.join('core', 'Linux', 'create_item.sh'),
        'mod_manager_help': os.path.join('core', 'Linux', 'mod_manager_help.sh'),
        'create_recipe': os.path.join('core', 'Linux', 'create_recipe.sh'),
        'create_model': os.path.join('core', 'Linux', 'create_model.sh'),
        'create_sound': os.path.join('core', 'Linux', 'create_sound.sh')
    }
}

# constant variable defining the types of mods available and their child folders
MOD_TYPES = {
    "Animation": [
        "anims",
        "animscript",
        "AnimSets",
        "animsold",
        "animstates",
        "anims_X"
    ],
    "Clothing": [
        "clothing",
        "hairStyles"
    ],
    "Fonts": [
        "font",
        "fonts"
    ],
    "Textures": [
        "geomTextures",
        "textures",
        "texturepacks"
    ],
    "Sound": [
        "sound",
        "music"
    ],
    "Models": [
        "models",
        "models_X",
        "gibs"
    ],
    "Items": [
        "scripts",
        "scripts/clothing",
        "scripts/vehicles",
        "scripts/weapons",
    ],
    "Maps": [
        "maps",
        "heightmaps"
    ],
    "Lua": [
        "lua",
        "lua/shared",
        "lua/client",
        "lua/server"
    ],
    "Ui": [
        "ui",
    ]
}

# Set up logging
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filemode='a'
)

# Mod manager class
class ModManager:
    """
    Main mod manager class that handles all mod-related operations.
    """
    def __init__(self):
        """Initialize the mod manager with platform detection and registry loading."""
        self.platform = self._get_platform()
        self.registry = self.load_config()
        self.item_types = ["Weapon", "Food", "Clothing", "Literature", "Drainable", "Radio", "Alarm Clock", "Key", "Tool"]

    @staticmethod
    def _get_platform() -> str:
        """Detects the platform (Windows or Unix)."""
        if os.name == 'nt':
            return 'windows'
        elif os.name == 'posix':
            return 'unix'
        raise EnvironmentError("Unsupported Operating System")
    
    def get_script_path(self, script_name: str) -> str:
        """Get the platform-specific path for a script."""
        try:
            script_path = os.path.abspath(SCRIPT_PATHS[self.platform][script_name])
            if not os.path.exists(script_path):
                raise FileNotFoundError(f"Script not found: {script_path}")
            return script_path
        except KeyError:
            raise NotImplementedError(f"Script '{script_name}' not available for platform {self.platform}")

    def load_config(self) -> Dict[str, Any]:
        """Load or create the configuration file."""
        try:
            if not os.path.exists(REGISTRY_FILE):
                logging.info("Config file not found. Creating new one.")
                # Create directory structure if it doesn't exist
                os.makedirs(os.path.dirname(REGISTRY_FILE), exist_ok=True)
                # Create file with empty JSON object
                with open(REGISTRY_FILE, 'w') as f:
                    json.dump({}, f)
                return {}
            
            with open(REGISTRY_FILE, "r") as f:
                return json.load(f)
        except json.JSONDecodeError:
            logging.error("Config file is corrupted. Creating new one.")
            # Overwrite corrupted file with empty JSON
            with open(REGISTRY_FILE, 'w') as f:
                json.dump({}, f)
            return {}

    def save_config(self) -> None:
        """Save the current configuration to file."""
        try:
            with open(REGISTRY_FILE, "w") as f:
                json.dump(self.registry, f, indent=4)
            logging.info("Configuration saved successfully.")
        except Exception as e:
            logging.error(f"Failed to save configuration: {e}")
            raise

    def install_mod(self, mod_name: str) -> None:
        """Install a mod by invoking the platform-specific install script."""
        if mod_name not in self.registry:
            logging.error(f"Mod '{mod_name}' not found in config.")
            print(f"Error: Mod '{mod_name}' is not registered.")
            return

        mod_path = self.registry[mod_name].get("mod_path")
        if not mod_path or not os.path.isdir(mod_path):
            logging.error(f"Invalid or missing mod path for '{mod_name}': {mod_path}")
            print(f"Error: Invalid mod path for '{mod_name}'")
            return

        try:
            script = self.get_script_path('install_mod')
            
            if self.platform == 'windows':
                cmd = [script, mod_name, mod_path]
            else:
                cmd = ['bash', script, mod_name, mod_path]

            subprocess.run(cmd, check=True, shell=False)
            logging.info(f"Successfully installed mod: {mod_name}")
            print(f"Successfully installed mod: {mod_name}")
        except subprocess.CalledProcessError as e:
            logging.error(f"Installation failed for '{mod_name}': {e}")
            print(f"Installation failed for '{mod_name}'. Check logs for details.")
        except Exception as e:
            logging.error(f"Unexpected error during installation: {e}")
            print(f"An unexpected error occurred: {e}")

    def create_recipe(self, mod_name: str, recipe_name: str, recipe_type: str, result_item: str) -> None:
        """Create a new recipe for a mod."""
        if mod_name not in self.registry:
            print(f"Error: Mod '{mod_name}' is not registered.")
            return
        
        mod_path = os.path.abspath(self.registry[mod_name]["mod_path"])
        
        try:
            script_path = self.get_script_path('create_recipe')
        except Exception as e:
            print(f"Error: {e}")
            return
        
        if not os.path.exists(mod_path):
            print(f"Error: Mod path does not exist: {mod_path}")
            return
        
        recipe_types = ["Standard", "Crafting", "Medical", "Carpentry", "Mechanics"]
        
        if recipe_type not in recipe_types:
            print(f"Error: Invalid recipe type. Choose from: {', '.join(recipe_types)}")
            return
        
        ingredients = []
        print("\nAdd ingredients for the recipe (type 'done' when finished):")
        
        # while loop for capturing user input to be placed in the ingredients array
        while True:
            ingredient = input("Ingredient name (or 'done' to finish): ").strip()
            if ingredient.lower() == 'done':
                break
                
            count = input(f"How many '{ingredient}' are needed? ").strip()
            try:
                count = int(count)
            except ValueError:
                print("Please enter a valid number.")
                continue
                
            ingredients.append(f"{ingredient}:{count}")
        
        if not ingredients:
            print("Error: At least one ingredient is required.")
            return
        
        ingredients_str = ",".join(ingredients)
        
        result_count = input(f"How many '{result_item}' does this recipe produce? ").strip()
        try:
            result_count = int(result_count)
        except ValueError:
            print("Using default value of 1.")
            result_count = 1
        
        recipe_time = input("How much time does this recipe take (in minutes)? ").strip()
        try:
            recipe_time = int(recipe_time)
        except ValueError:
            print("Using default value of 100.")
            recipe_time = 100
        
        skill_type = input("Required skill (leave blank for none): ").strip()
        skill_level = "0"
        
        if skill_type:
            skill_level_input = input(f"Required level for {skill_type}: ").strip()
            try:
                skill_level = str(int(skill_level_input))
            except ValueError:
                print("Using default value of 0.")
                skill_level = "0"
        
        # try block for constructing and running the actual process to execute the linux/windows scripts
        try:
            cmd = [script_path, mod_name, recipe_name, recipe_type, result_item, 
                  str(result_count), str(recipe_time), ingredients_str]
            
            if skill_type:
                cmd.extend([skill_type, skill_level])
            else:
                cmd.extend(["", ""])
            
            cmd.append(mod_path)
            
            if self.platform == 'unix':
                cmd.insert(0, 'bash')
            
            print(f"Executing: {' '.join(cmd)}")
            
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            time.sleep(0.5)
            
            print(result.stdout)
            if result.stderr:
                print(f"Error output: {result.stderr}")
            
            expected_file = os.path.join(mod_path, "media", "scripts", f"{mod_name}_Recipes.txt")
            if os.path.exists(expected_file):
                print(f"Successfully created recipe: {recipe_name}")
                print(f"Recipe file location: {expected_file}")
            else:
                print(f"Warning: Recipe created but file not found at expected location: {expected_file}")
        except subprocess.CalledProcessError as e:
            print(f"Failed to create recipe: {e}")
            print(f"Error output: {e.stderr}")
            logging.error(f"Recipe creation failed for {mod_name}: {e}")

    def create_model(self, mod_name: str, model_name: str) -> None:
        """Create a new model for a mod."""
        if mod_name not in self.registry:
            print(f"Error: Mod '{mod_name}' is not registered")
            logging.error(f"Mod '{mod_name}' not found in registry")
            return

        mod_path = self.registry[mod_name]["mod_path"]
        
        try:
            script = self.get_script_path('create_model')
        except Exception as e:
            print(f"Error: {e}")
            return

        try:
            if self.platform == 'windows':
                cmd = [script, mod_name, mod_path, model_name]
            else:
                cmd = ['bash', script, mod_name, mod_path, model_name]

            subprocess.run(cmd, check=True, shell=False)
            logging.info(f"Successfully created model: {model_name} for mod: {mod_name}")
            print(f"Successfully created model: {model_name}")
        except subprocess.CalledProcessError as e:
            logging.error(f"Model creation failed for '{mod_name}': {e}")
            print(f"Model creation failed for '{mod_name}'. Check logs for details.")

    def create_sound(self, mod_name: str, sound_type: str, sound_name: str, **kwargs) -> None:
        """Create a new sound for a mod."""
        if mod_name not in self.registry:
            print(f"Error: Mod '{mod_name}' is not registered")
            logging.error(f"Mod '{mod_name}' not found in registry")
            return

        mod_path = self.registry[mod_name]["mod_path"]
        
        try:
            script_path = self.get_script_path('create_sound')
        except Exception as e:
            print(f"Error: {e}")
            return

        ## define arguments in an array and append extra arguments in a key value syntax
        arguments = [mod_name, sound_type, sound_name, mod_path]
        for key, value in kwargs.items():
            arguments.append(f"{key}={value}")

        logging.info(f"Running script: {script_path} with arguments: {arguments}")
        print(f"Running script: {script_path} with arguments: {arguments}")

        # try block that handles the script selection and executes the correct type based on the operating system
        try:
            if self.platform == 'windows':
                cmd = [script_path] + arguments
            else:
                cmd = ['bash', script_path] + arguments

            subprocess.run(cmd, check=True, shell=False)
            logging.info(f"Successfully created or updated sound: {sound_name}")
            print(f"Successfully created or updated sound: {sound_name}")
        except subprocess.CalledProcessError as e:
            logging.error(f"Failed to run script for '{sound_name}': {e}")
            print(f"Failed to run script for '{sound_name}'. Check logs for details.")

    def list_recipe_types(self) -> None:
        """Display all supported recipe types."""
        recipe_types = ["Standard", "Crafting", "Medical", "Carpentry", "Mechanics"]
        print("\nSupported Recipe Types:")
        for i, recipe_type in enumerate(recipe_types, 1):
            print(f"{i}. {recipe_type}")

    def create_mod(self, mod_name: str, mod_path: str) -> None:
        """Register a new mod in the configuration."""
        if mod_name in self.registry:
            logging.warning(f"Mod '{mod_name}' already exists.")
            print(f"Warning: Mod '{mod_name}' already exists.")
            return

        if not os.path.exists(mod_path):
            logging.error(f"Invalid path provided: {mod_path}")
            print(f"Error: The path '{mod_path}' does not exist.")
            return

        try:
            script = self.get_script_path('create_mod')
            self.registry[mod_name] = {"mod_path": os.path.abspath(os.path.join(mod_path, mod_name))}
            self.save_config()

            if self.platform == 'windows':
                subprocess.run([script, mod_name, mod_path], shell=False, check=True)
            else:
                subprocess.run(['bash', script, mod_name, mod_path], shell=False, check=True)
            
        except subprocess.CalledProcessError as e:
            logging.error(f"Failed to run mod creation script: {e}")
            print("Error: Could not run mod setup script.")
            return


        print("\nAvailable mod types:")
        for i, mod_type in enumerate(MOD_TYPES.keys(), 1):
            print(f"{i}. {mod_type}")

        selected_types = []
        while True:
            selected = input("Enter a mod type to add (or type 'quit' to finish): ").strip().capitalize()
            if selected == 'Quit':
                break
            if selected not in MOD_TYPES:
                print(f"Invalid mod type '{selected}'. Try again.")
                continue
            selected_types.append(selected)

        if selected_types:
            selected_folders = []
            for selected in selected_types:
                selected_folders.extend(MOD_TYPES[selected])

            try:
                if self.platform == 'windows':
                    cmd = [script, mod_name, mod_path] + selected_folders
                    subprocess.run(cmd, shell=False, check=True)
                else:
                    cmd = ['bash', script, mod_name, mod_path] + selected_folders
                    subprocess.run(cmd, shell=False, check=True)
                    
                logging.info(f"Created structure for mod: {mod_name} with folders: {', '.join(selected_folders)}")
                print(f"Successfully created mod structure for: {mod_name}")
            except subprocess.CalledProcessError as e:
                logging.error(f"Failed to create folders for mod '{mod_name}': {e}")
                print(f"Error creating folders for mod '{mod_name}'.")

        logging.info(f"Created new mod: {mod_name}")
        print(f"Successfully registered mod: {mod_name}")

    def register_mod(self, mod_name: str, mod_path: str) -> None:
        """Register an existing mod in the registry."""
        if mod_name in self.registry:
            logging.warning(f"Mod '{mod_name}' already exists in registry.")
            print(f"Warning: Mod '{mod_name}' already exists in registry.")
            return
        
        full_path = os.path.abspath(mod_path)
        if not os.path.exists(full_path):
            logging.error(f"Invalid path provided: {full_path}")
            print(f"Error: The path '{full_path}' does not exist.")
            return
        
        self.registry[mod_name] = {"mod_path": full_path}
        self.save_config()
        
        logging.info(f"Registered existing mod: {mod_name} at {full_path}")
        print(f"Successfully registered mod: {mod_name}")

    def flush_registry(self):
        """Clear the mod registry."""
        try:
            with open(REGISTRY_FILE, 'w'):
                print("Flushed registry.")
        except Exception as e:
            print(f"Error occurred while flushing registry: {e}")

    def create_item(self, mod_name: str, item_type: str, item_name: str) -> None:
        """Create a new item for a mod."""
        if mod_name not in self.registry:
            print(f"Error: Mod '{mod_name}' is not registered.")
            return

        if item_type not in self.item_types:
            print(f"Error: Invalid item type. Choose from: {', '.join(self.item_types)}")
            return

        mod_path = self.registry[mod_name]["mod_path"]
        
        try:
            script_path = self.get_script_path('create_item')
        except Exception as e:
            print(f"Error: {e}")
            return

        try:
            if self.platform == 'windows':
                cmd = [script_path, mod_name, item_type, item_name, mod_path]
            else:
                cmd = ['bash', script_path, mod_name, item_type, item_name, mod_path]

            subprocess.run(cmd, check=True, shell=False)
            print(f"Successfully created {item_type} item: {item_name}")
        except subprocess.CalledProcessError as e:
            print(f"Failed to create item: {e}")
            logging.error(f"Item creation failed for {mod_name}: {e}")

    def list_item_types(self) -> None:
        """Display all supported item types."""
        print("\nSupported Item Types:")
        for i, item_type in enumerate(self.item_types, 1):
            print(f"{i}. {item_type}")

    def list_mods(self) -> None:
        """List all registered mods."""
        if not self.registry:
            print("No mods registered.")
            return

        print("\nRegistered Mods:")
        for i, (mod_name, mod_data) in enumerate(self.registry.items(), 1):
            print(f"{i}. {mod_name}: {mod_data['mod_path']}")

    def delete_mod(self, mod_name: str) -> None:
        """Remove a mod from the configuration."""
        if mod_name not in self.registry:
            print(f"Error: Mod '{mod_name}' not found.")
            return

        del self.registry[mod_name]
        self.save_config()
        print(f"Removed mod: {mod_name}")

    def validate_mod_paths(self) -> None:
        """Check if all registered mod paths still exist."""
        invalid_mods = []
        for mod_name, mod_data in self.registry.items():
            if not os.path.exists(mod_data["mod_path"]):
                invalid_mods.append(mod_name)

        if invalid_mods:
            print("Warning: The following mods have invalid paths:")
            for mod in invalid_mods:
                print(f"- {mod}")
            print("Check mod manager registry file for invalid entry.")
        else:
            print("All mod paths are valid.")

def display_help():
    """Display help information."""
    try:
        script_path = os.path.abspath(SCRIPT_PATHS[ModManager().platform]['mod_manager_help'])
        if ModManager().platform == 'windows':
            subprocess.run([script_path], check=True, shell=False)
        else:
            subprocess.run(['bash', script_path], check=True, shell=False)
    except Exception as e:
        print(f"Error displaying help: {e}")

def show_ascii_logo():
    """Display the ASCII logo."""
    try:
        logo_path = os.path.join("core", "logo.txt")
        with open(logo_path, "r", encoding="utf-8") as file:
            print(file.read())
    except FileNotFoundError:
        print("Project Zomboid Mod Manager")

def main():
    """Main application entry point."""
    manager = ModManager()
    print(f"Project Zomboid Mod Manager (Running on {manager.platform})")
    show_ascii_logo()
    display_help()

    while True:
        try:
            command = input("\n> ").strip().lower()
            
            if command in ('exit', 'quit'):
                print("Goodbye!")
                break
            elif command == 'help':
                display_help()
            elif command == 'create':
                mod_name = input("Mod name: ").strip()
                mod_path = input("Mod directory path: ").strip()
                manager.create_mod(mod_name, mod_path)
            elif command == 'register':
                mod_name = input("Mod name: ").strip()
                mod_path = input("Existing mod directory path: ").strip()
                manager.register_mod(mod_name, mod_path)
            elif command == 'recipe':
                mod_name = input("Mod name to add recipe to: ").strip()
                if mod_name in manager.registry:
                    manager.list_recipe_types()
                    recipe_type = input("Recipe type: ").strip()
                    recipe_name = input("Recipe name: ").strip()
                    result_item = input("Result item: ").strip()
                    manager.create_recipe(mod_name, recipe_name, recipe_type, result_item)
                else:
                    print(f"Error: Mod '{mod_name}' is not registered.")
            elif command == 'item':
                mod_name = input("Mod name to add item to: ").strip()
                manager.list_item_types()
                item_type = input("Item type: ").strip()
                item_name = input("Item name: ").strip()
                manager.create_item(mod_name, item_type, item_name)
            elif command == 'itemtypes':
                manager.list_item_types()
            elif command == 'model':
                mod_name = input("Mod name: ").strip()
                model_name = input("Model name: ").strip()
                manager.create_model(mod_name, model_name)
            elif command == 'sound':
                mod_name = input("Mod name: ").strip()
                sound_type = input("Sound type (e.g., SFX, Music, etc.): ").strip()
                sound_name = input("Sound name: ").strip()
                sound_path = input("Sound file path (e.g., C:\\Sounds\\ZombieGrowl.wav): ").strip()
                volume = input("Volume (default is 1.0): ").strip() or "1.0"
                looping = input("Looping (true/false, default is false): ").strip().lower() or "false"
                manager.create_sound(mod_name, sound_type, sound_name, sound_path=sound_path, volume=volume, looping=looping)
            elif command == 'list':
                manager.list_mods()
            elif command == 'install':
                mod_name = input("Mod name to install: ").strip()
                manager.install_mod(mod_name)
            elif command == 'delete':
                mod_name = input("Mod name to remove: ").strip()
                manager.delete_mod(mod_name)
            elif command == 'flush':
                manager.flush_registry()
            elif command == 'validate':
                manager.validate_mod_paths()
            else:
                print("Unknown command. Type 'help' for available commands.")
                
        except KeyboardInterrupt:
            print("\nUse 'exit' to quit the program.")
        except Exception as e:
            logging.error(f"Unexpected error: {e}")
            print(f"An error occurred. See {LOG_FILE} for details.")

# catch all that runs the main program (main menu) on startup unless their was an exception
if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logging.critical(f"Critical error: {e}")
        print(f"A critical error occurred. Check {LOG_FILE} for details.")
        sys.exit(1)