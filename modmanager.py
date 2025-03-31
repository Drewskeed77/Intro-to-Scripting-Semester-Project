import os
import json
import subprocess
import sys
import logging
from pathlib import Path
from typing import Dict, Any, Optional, List

# Constants
CONFIG_FILE = "modmanager_config.json"
LOG_FILE = "modmanager.log"
WINDOWS_SCRIPT = './Windows/install_mod.bat'
UNIX_SCRIPT = './Linux/install_mod.sh'
CREATE_ITEM_SCRIPT = './Windows/create_item.bat'

# Set up logging
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filemode='a'
)

# Create class for all mod actions
class ModManager:
    def __init__(self):
        self.platform = self._get_platform()  # Changed to _get_platform to match method name
        self.config = self.load_config()
        self.item_types = ["Weapon", "Food", "Clothing", "Literature", "Drainable", "Radio", "Alarm Clock", "Key", "Tool"]

    # Method for determining what platfrom we are currently using
    @staticmethod
    def _get_platform() -> str:  # Renamed to _get_platform for consistency
        """Detects the platform (Windows or Unix)."""
        if os.name == 'nt':
            return 'windows'
        elif os.name == 'posix':
            return 'unix'
        raise EnvironmentError("Unsupported Operating System")

    # Loads the modmanager_config file
    def load_config(self) -> Dict[str, Any]:
        """Load or create the configuration file."""
        try:
            if not os.path.exists(CONFIG_FILE):
                logging.info("Config file not found. Creating new one.")
                return {}
            
            with open(CONFIG_FILE, "r") as f:
                return json.load(f)
        except json.JSONDecodeError:
            logging.error("Config file is corrupted. Creating new one.")
            return {}
    # Saves to the modmanager_config file

    def save_config(self) -> None:
        """Save the current configuration to file."""
        try:
            with open(CONFIG_FILE, "w") as f:
                json.dump(self.config, f, indent=4)
            logging.info("Configuration saved successfully.")
        except Exception as e:
            logging.error(f"Failed to save configuration: {e}")
            raise

    # Installs a mod ( copies from another valid mod folder for right now) to the current directory its called from
    def install_mod(self, mod_name: str) -> None:
        """Install a mod using platform-specific scripts."""
        if mod_name not in self.config:
            logging.error(f"Mod '{mod_name}' not found in config.")
            print(f"Error: Mod '{mod_name}' is not registered.")
            return

        mod_path = self.config[mod_name].get("mod_path", "")
        if not mod_path or not os.path.exists(mod_path):
            logging.error(f"Invalid mod path for '{mod_name}': {mod_path}")
            print(f"Error: Invalid mod path for '{mod_name}'")
            return

        script = WINDOWS_SCRIPT if self.platform == 'windows' else UNIX_SCRIPT
        if not os.path.exists(script):
            logging.error(f"Install script not found: {script}")
            print(f"Error: Install script not found at {script}")
            return

        try:
            subprocess.run([script, mod_name, mod_path], check=True)
            logging.info(f"Successfully installed mod: {mod_name}")
            print(f"Successfully installed mod: {mod_name}")
        except subprocess.CalledProcessError as e:
            logging.error(f"Installation failed for {mod_name}: {e}")
            print(f"Installation failed for {mod_name}. See log for details.")

    # adds a mod to the modmanager_config file for caching validation etc
    def create_mod(self, mod_name: str, mod_path: str) -> None:
        """Register a new mod in the configuration."""
        if mod_name in self.config:
            logging.warning(f"Mod '{mod_name}' already exists.")
            print(f"Warning: Mod '{mod_name}' already exists.")
            return

        if not os.path.exists(mod_path):
            logging.error(f"Invalid path provided: {mod_path}")
            print(f"Error: The path '{mod_path}' does not exist.")
            return

        self.config[mod_name] = {"mod_path": os.path.abspath(mod_path)}
        self.save_config()
        logging.info(f"Created new mod: {mod_name}")
        print(f"Successfully registered mod: {mod_name}")

    # function responsible for running the create item scripts
    def create_item(self, mod_name: str, item_type: str, item_name: str) -> None:
        """Create a new item for a mod using the batch script."""
        if mod_name not in self.config:
            print(f"Error: Mod '{mod_name}' is not registered.")
            return

        if item_type not in self.item_types:
            print(f"Error: Invalid item type. Choose from: {', '.join(self.item_types)}")
            return

        if self.platform != 'windows':
            print("Item creation currently only supported on Windows")
            return

        mod_path = self.config[mod_name]["mod_path"]
        script_path = os.path.abspath(CREATE_ITEM_SCRIPT)

        if not os.path.exists(script_path):
            print(f"Error: Item creation script not found at {script_path}")
            return

        try:
            subprocess.run(
                [script_path, mod_name, item_type, item_name],
                cwd=mod_path,
                check=True
            )
            print(f"Successfully created {item_type} item: {item_name}")
        except subprocess.CalledProcessError as e:
            print(f"Failed to create item: {e}")
            logging.error(f"Item creation failed for {mod_name}: {e}")

    # list the valid types of items we can use
    def list_item_types(self) -> None:
        """Display all supported item types."""
        print("\nSupported Item Types:")
        for i, item_type in enumerate(self.item_types, 1):
            print(f"{i}. {item_type}")

    # lsit the current mods that are registerd
    def list_mods(self) -> None:
        """List all registered mods."""
        if not self.config:
            print("No mods registered.")
            return

        print("\nRegistered Mods:")
        for i, (mod_name, mod_data) in enumerate(self.config.items(), 1):
            print(f"{i}. {mod_name}: {mod_data['mod_path']}")

    # deleted mod from the config file
    def delete_mod(self, mod_name: str) -> None:
        """Remove a mod from the configuration."""
        if mod_name not in self.config:
            print(f"Error: Mod '{mod_name}' not found.")
            return

        del self.config[mod_name]
        self.save_config()
        print(f"Removed mod: {mod_name}")

    # validate mod paths to check if they are valid on the current os
    def validate_mod_paths(self) -> None:
        """Check if all registered mod paths still exist."""
        invalid_mods = []
        for mod_name, mod_data in self.config.items():
            if not os.path.exists(mod_data["mod_path"]):
                invalid_mods.append(mod_name)

        if invalid_mods:
            print("Warning: The following mods have invalid paths:")
            for mod in invalid_mods:
                print(f"- {mod}")
        else:
            print("All mod paths are valid.")

# help display command function to help with using the cli
def display_help() -> None:
    """Display help information."""
    print("\nProject Zomboid Mod Manager")
    print("Commands:")
    print("  create      - Register a new mod")
    print("  item        - Create a new item for a mod")
    print("  itemtypes   - List available item types")
    print("  list        - List all registered mods")
    print("  install     - Install a registered mod")
    print("  delete      - Remove a mod from registry")
    print("  validate    - Check all mod paths")
    print("  exit        - Quit the program")
    print("  help        - Show this help message")

# Main app execution
def main():
    manager = ModManager()
    print(f"Project Zomboid Mod Manager (Running on {manager.platform})")
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
                
            elif command == 'item':
                mod_name = input("Mod name to add item to: ").strip()
                manager.list_item_types()
                item_type = input("Item type: ").strip()
                item_name = input("Item name: ").strip()
                manager.create_item(mod_name, item_type, item_name)
                
            elif command == 'itemtypes':
                manager.list_item_types()
                
            elif command == 'list':
                manager.list_mods()
                
            elif command == 'install':
                mod_name = input("Mod name to install: ").strip()
                manager.install_mod(mod_name)
                
            elif command == 'delete':
                mod_name = input("Mod name to remove: ").strip()
                manager.delete_mod(mod_name)
                
            elif command == 'validate':
                manager.validate_mod_paths()
                
            else:
                print("Unknown command. Type 'help' for available commands.")
                
        except KeyboardInterrupt:
            print("\nUse 'exit' to quit the program.")
        except Exception as e:
            logging.error(f"Unexpected error: {e}")
            print(f"An error occurred. See {LOG_FILE} for details.")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logging.critical(f"Critical error: {e}")
        print(f"A critical error occurred. Check {LOG_FILE} for details.")
        sys.exit(1)