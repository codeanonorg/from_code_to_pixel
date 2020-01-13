import array
import pygame
from pygame.locals import *


def get_x(b):
    return (b >> 8) & 0xF


def get_y(b):
    return (b >> 12) & 0xF


def get_kk(b):
    return b & 0xFF


def get_nnn(b):
    return b & 0xFFF


def get_n(b):
    return b & 0xF


def get_opcode(a, b):
    return (a << 8) | b


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
            K_r: False,
            K_q: False,
            K_s: False,
            K_d: False,
            K_f: False,
            K_w: False,
            K_x: False,
            K_c: False,
            K_v: False
        }

        self.key_val = {
            K_a: 0x4,
            K_z: 0x5,
            K_e: 0x6,
            K_r: 0xD,
            K_q: 0x7,
            K_s: 0x8,
            K_d: 0x9,
            K_f: 0xE,
            K_w: 0xA,
            K_x: 0x0,
            K_c: 0xB,
            K_v: 0xF
        }

    def safe_register(self, reg):
        return 0 <= reg < self.registers_num

    def safe_value(self, val):
        return 0 <= val <= 255

    def safe_address(self, adr):
        return 0 <= adr <= self.ram_size

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

    def do_add_val(self, reg, val):
        """ 7xkk - ADD Vx, byte """
        assert self.safe_register(reg), f"register error [{reg}]"
        assert self.safe_value(val), f"value error [{val}]"
        _sum = self.registers[reg] + val
        if _sum > 255:
            self.registers[reg] = _sum
        else:
            self.registers[reg] = 255

    def do_add_reg(self, reg0, reg1):
        """ 8xy4 - ADD Vx, Vy """
        assert self.safe_register(reg0), f"register error [{reg0}]"
        assert self.safe_register(reg1), f"register error [{reg1}]"
        _sum = self.registers[reg0] + self.registers[reg1]
        if _sum > 255:
            self.registers[reg0] = _sum
        else:
            self.registers[reg0] = 255

    def do_add_pointer(self, reg):
        """ Fx1E - ADD I, Vx """
        assert self.safe_register(reg), f"register error [{reg}]"
        self.address_register += self.registers[reg]
        assert self.safe_address(
            self.address_register), f"address error [{reg}]"

    def do_sub_reg(self, reg0, reg1):
        """ 8xy5 - SUB Vx, Vy """
        assert self.safe_register(reg0), f"register error [{reg0}]"
        assert self.safe_register(reg1), f"register error [{reg1}]"
        _sub = self.registers[reg0] - self.registers[reg1]
        if _sub >= 0:
            self.registers[reg0] = _sub
        else:
            self.registers[reg0] = 0

    def do_load_address(self, adr):
        """ Annn - LD I, addr """
        assert self.safe_address(adr), f"address error [{adr}]"
        self.address_register = adr

    def do_load_value(self, reg, val):
        """ 6xkk - LD Vx, byte """
        assert self.safe_register(reg), f"register error [{adr}]"
        assert self.safe_value(val), f"value error [{val}]"
        self.registers[reg] = val

    def do_load_key(self, reg):
        """ Fx0A - LD Vx, K """
        assert self.safe_register(reg), f"register error [{reg}]"
        pressed = False
        for key in self.keyboard:
            if self.keyboard[key]:
                self.registers[reg] = self.key_val[key]
                pressed = True

        if not pressed:
            self.program_counter -= 2

    def do_skip_if_equal(self, reg, val):
        """ 3xkk - SE Vx, byte """
        assert self.safe_register(reg), f"register error [{adr}]"
        assert self.safe_value(val), f"value error [{val}]"
        if self.registers[reg] == val:
            self.program_counter += 2

    def do_skip_if_not_equal(self, reg, val):
        """ 4xkk - SNE Vx, byte """
        assert self.safe_register(reg), f"register error [{reg}]"
        assert self.safe_value(val), f"value error [{val}]"
        if self.registers[reg] != val:
            self.program_counter += 2

    def do_jump(self, adr):
        """ 1nnn - JP addr """
        assert self.safe_address(adr), f"value error [{adr}]"
        self.program_counter = adr

    def do_draw(self, reg0, reg1, nibble):
        """ Dxyn - DRW Vx, Vy, nibble """
        assert self.safe_register(reg0), f"register error [{reg0}]"
        assert self.safe_register(reg1), f"register error [{reg1}]"
        assert self.safe_value(nibble), f"value error [{val}]"
        _x = self.registers[reg0]
        _y = self.registers[reg1]
        for i in range(nibble):
            for j in range(8):
                _sprite = self.memory[self.address_register+i]
                if ((_sprite >> (8-j-1)) & 0x0001) == 1:
                    if self.screen_buff[_x+j][_y+i] == 1:
                        # COLLISION
                        self.registers[15] = 1
                    self.screen_buff[_x+j][_y+i] = 1

    def execute_next_instruction(self):
        # ============================
        # L'objectif de cet atelier est de compléter cette fonction
        # ....
        # ....
        # ============================
        _hig = self.memory[self.program_counter]
        _low = self.memory[self.program_counter+1]
        opcode = get_opcode(_hig, _low)
        _x = get_x(opcode)
        _y = get_y(opcode)
        _n = get_n(opcode)
        _kk = get_kk(opcode)
        _nnn = get_nnn(opcode)

        if ((opcode >> 12) & 0xF) == 0xA:
            self.do_load_address(_nnn)
        elif ((opcode >> 12) & 0xF) == 0xD:
            self.do_draw(_x, _y, _n)
        elif ((opcode >> 12) & 0xF) == 0xD:
            pass
        # ...

        self.program_counter += 2

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
vm.read_rom("./clou_asm.rom")
vm.start()
