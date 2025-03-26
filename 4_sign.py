import base64,hashlib,sys

class PrivateKey():
    ''' Extract private key parameters
    '''
    def __init__(self,filename):
        def read02(buf):
            ''' Read DER encoded integer
            '''
            assert buf[0] == 0x02
            i = buf[1]-0x80
            l = int.from_bytes(buf[2:2+i],'big')
            return int.from_bytes(buf[2+i:2+i+l],'big')

        data = base64.b64decode("".join([l for l in open(filename).readlines() if '-' not in l]))
        if data[7] == 0x02:  # PKCS#1
            pass
        elif data[7] == 0x30: # PKCS#7
            data = data[26:]
        else:
            assert False

        self.n = read02(data[7:])
        self.d = read02(data[273:])

def calc_signature(filename, data):
    pkey = PrivateKey(filename)
    hash = hashlib.sha256()
    hash.update(data)
    block = int.from_bytes(b'\x00\x01' + b'\xff' * 202 + bytes.fromhex('003031300d060960864801650304020105000420') + hash.digest(),'big')
    return pow(block,pkey.d,pkey.n).to_bytes(256,byteorder='big')

if __name__ == "__main__":
    # equivalent to "openssl dgst -sha256 -sign $1"
    data = sys.stdin.buffer.read()
    sig = calc_signature(sys.argv[1], data)
    sys.stdout.buffer.write(sig)
