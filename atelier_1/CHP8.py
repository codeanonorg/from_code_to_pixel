import array
import pygame
from pygame.locals import *


class CHP8:
    def __init__(self, stack_size=16, registers=16):
        # technical specifications
        self.ram_size = 250
        self.stack_size = stack_size
        self.registers_num = registers

        # init
        pygame.init()
        self.screen = pygame.display.set_mode((640, 320))

        # RAM
        self.memory = array.array('B', [0 for _ in range(self.ram_size)])
        # UTILS REGISTERS
        self.registers = array.array(
            'B', [0 for _ in range(self.registers_num)])
        # ADDRESS REGISTER
        self.address_register = 0
        # STACK
        self.stack = array.array('B', [0 for _ in range(self.stack_size)])
        # PROGRAM COUNTER
        self.program_counter = 0

        self.screen_buff = [[0 for i in range(32)] for j in range(64)]

        # KEYBOARD STATE
        self.keyboard = {
            K_a: False,
            K_z: False,
            K_e: False,
            K_q: False,
            K_s: False,
            K_d: False,
            K_w: False,
            K_x: False,
            K_c: False
        }

    def safe_register(self, reg):
        return 0 <= reg < self.registers_num

    def safe_value(self, val):
        return 0 <= val <= 255

    def safe_address(self, adr):
        return 0 <= adr <= self.ram_size

    def do_add_reg(self, reg0, reg1):
        assert self.safe_register(reg0), f"register error [{reg0}]"
        assert self.safe_register(reg1), f"register error [{reg1}]"
        _sum = self.registers[reg0] + self.registers[reg1]
        if _sum > 255:
            self.registers[reg0] = _sum
        else:
            self.registers[reg0] = 255

    def do_sub_reg(self, reg0, reg1):
        assert self.safe_register(reg0), f"register error [{reg0}]"
        assert self.safe_register(reg1), f"register error [{reg1}]"
        _sub = self.registers[reg0] - self.registers[reg1]
        if _sub >= 0:
            self.registers[reg0] = _sub
        else:
            self.registers[reg0] = 0

    def do_load_address(self, adr):
        assert self.safe_address(adr), f"address error [{adr}]"
        self.address_register = adr

    def do_load_value(self, reg, val):
        assert self.safe_register(reg), f"register error [{adr}]"
        assert self.safe_value(val), f"value error [{val}]"
        self.registers[reg] = val

    def do_skip_if_equal(self, reg, val):
        assert self.safe_register(reg), f"register error [{adr}]"
        assert self.safe_value(val), f"value error [{val}]"
        if self.registers[reg] == val:
            self.program_counter += 2

    def do_skip_if_not_equal(self, reg, val):
        assert self.safe_register(reg), f"register error [{reg}]"
        assert self.safe_value(val), f"value error [{val}]"
        if self.registers[reg] != val:
            self.program_counter += 2

    def do_jump(self, adr):
        assert self.safe_address(adr), f"value error [{adr}]"
        self.program_counter = adr

    def do_draw(self, reg0, reg1, val):
        assert self.safe_register(reg0), f"register error [{reg0}]"
        assert self.safe_register(reg1), f"register error [{reg1}]"
        assert self.safe_value(val), f"value error [{val}]"
        _x = self.registers[reg0]
        _y = self.registers[reg1]
        for i in range(val):
            for j in range(8):
                _sprite = self.memory[self.address_register+i]
                if ((_sprite >> (8-j-1)) & 0x0001) == 1:
                    if self.screen_buff[_x+j][_y+i] == 1:
                        # COLLISION
                        self.registers[15] = 1
                    self.screen_buff[_x+j][_y+i] = 1

    def update_screen(self):
        white = pygame.Color(255, 255, 255)
        for x in range(64):
            for y in range(32):
                if(self.screen_buff[x][y] == 1):
                    rect = (x*10, y*10, 10, 10)
                    pygame.draw.rect(self.screen, white, rect)

    def update_keyboard_state(self):
        _state = pygame.key.get_pressed()
        for key in self.keyboard:
            self.keyboard[key] = _state[key]

    def execute_next_instruction(self):
        # ============================
        # L'objectif de cet atelier est de compléter cette fonction
        # ....
        # ....
        # ============================
        pass

    def read_rom(self, filename):
        with open(filename, 'rb') as f:
            self.memory[0] = int.from_bytes(f.read(1), "little")
            ram_i = 1
            while f != b'' and ram_i < self.ram_size:
                self.memory[ram_i] = int.from_bytes(f.read(1), "little")
                ram_i = ram_i+1

    def start(self):
        pygame.init()
        running = True
        clock = pygame.time.Clock()
        while running and self.program_counter < self.ram_size:
            # FPS
            clock.tick(30)

            # EVENT HANDLING
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False

            # CLEAN THE SCREEN
            self.screen.fill(pygame.Color(0, 0, 0))
            # UPDATE THE KEYBOARD STATE
            self.update_keyboard_state()
            # EXECUTE THE NEXT INSTRUCTION
            self.execute_next_instruction()
            # UPDATE THE SCREEN
            self.update_screen()
            pygame.display.flip()


vm = CHP8()
vm.read_rom("./atelier_1/clou_asm.rom")
vm.start()
