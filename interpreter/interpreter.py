import sys 

class Interpreter:

    def __init__(self, file):

        self.memory = [0]*10 # Espace pour Decalage + Val de Return
        self.memory += [0]*100 # Espace pour le main
        self.debutZoneMemoireFonc = 10
        self.accesAddresseRelative = 6
        self.decalageMax = self.memory[0] = 0

        self.file = file

    # Si on veut écrire dans les paramètres, variables ou variables temporaires
    # Alors on utilise le décalage (adresses relatives)
    # Sinon c'est qu'on visait les adresses absolues donc pas de décalage
    def toRelativeAddress(self,line):
        decalage = self.memory[0]

        operation = line[0]
        operandes = line[1:]
        operandes = [int(x) for x in operandes]

        # Peut être qu'il faut aussi check pour les autres operandes
        if operandes[0] > 100 : 
            print("ERREUR : Tentative d'overflow -> Ligne {}".format(self.execPointer))
            exit()

        # Pour chaque instruction le premier operande est toujours relatif
        if operandes[0] > self.accesAddresseRelative :
            operandes[0] += self.debutZoneMemoireFonc + decalage 
        
        # Operations devant mettre leur deuxième operande en relatif 
        if operation in ["ADD","MUL","DIV","SOU","CMP","NOT","COP"]:
            if operandes[1] > self.accesAddresseRelative :
                operandes[1] += self.debutZoneMemoireFonc + decalage 

        # Operations devant mettre leur troisième operande en relatif 
        if operation in ["ADD","MUL","DIV","SOU","CMP"]:
            if operandes[2] > self.accesAddresseRelative :
                operandes[2] += self.debutZoneMemoireFonc + decalage 

        return (operation, operandes)


    # ADD SOU DIV MUL | NOT AFC COP
    def modify(self,line):

        operation, operandes = self.toRelativeAddress(line)
            
        # Si on modifie le décalage c'est qu'on rentre dans une fonction
        # Il faut donc potentiellement allouer de la place au tableau python
        if operandes[0] == 0 and operation == "ADD" and self.memory[operandes[0]] > self.decalageMax:
            self.memory += [0]*100
            self.decalageMax += 100

        print(operation,operandes)
        # print(self.memory)

        match operation:
            case "ADD": self.memory[operandes[0]] = self.memory[operandes[1]] + self.memory[operandes[2]]
            case "MUL": self.memory[operandes[0]] = self.memory[operandes[1]] * self.memory[operandes[2]]
            case "SOU": self.memory[operandes[0]] = self.memory[operandes[1]] - self.memory[operandes[2]]
            case "DIV": self.memory[operandes[0]] = self.memory[operandes[1]] / self.memory[operandes[2]]
            case "CMP": self.memory[operandes[0]] = int(operandes[1] > operandes[2])
            case "NOT": self.memory[operandes[0]] = int(not operandes[1])
            case "AFC": self.memory[operandes[0]] = operandes[1]
            case "COP": self.memory[operandes[0]] = self.memory[operandes[1]]

    # --------

    def run(self):
        with open(self.file) as f:
            lines = f.readlines()

        self.execPointer = 0 
        while self.execPointer < len(lines) : 

            line = lines[self.execPointer]
            line = line.split()

            if line[0] in ["ADD","MUL","DIV","SOU","COP","AFC","CMP","NOT"]:
                self.modify(line)

            else :
                match line[0]:
                    case "NOP": pass
                    case "JMP": self.execPointer = int(line[1])

                    case "JMF": 
                        _, operandes = self.toRelativeAddress(line)
                        bool, dest = operandes
                        if not self.memory[bool] : 
                            self.execPointer = dest
                    
                    case "BX" : 
                        _, dest = self.toRelativeAddress(line)
                        self.execPointer = self.memory[dest[0]]

                    case "PRI": 
                        _, dest = self.toRelativeAddress(line)
                        print(self.memory[dest[0]])

                    case _: 
                        print("ERREUR : Commande ASM non reconnue -> Ligne {}".format(self.execPointer))
                        exit()

            self.execPointer += 1

if __name__ == "__main__":

    file = "./base.txt"
    if len(sys.argv) > 1 :
        file = sys.argv[1]
    
    interp = Interpreter(file)
    interp.run()