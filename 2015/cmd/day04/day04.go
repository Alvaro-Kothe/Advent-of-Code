package main

import (
	"bufio"
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"
)

func main() {
	reader := bufio.NewReader(os.Stdin)
	key, _ := reader.ReadString('\n')
	key = strings.TrimSpace(key)
	i := 0
	hasher := md5.New()
	p1 := -1
	p2 := -1
	for {
		i++
		io.WriteString(hasher, key)
		io.WriteString(hasher, strconv.Itoa(i))
		h := hasher.Sum(nil)
		hexStr := hex.EncodeToString(h)
		if p1 == -1 && strings.HasPrefix(hexStr, "00000") {
			p1 = i
		}
		if strings.HasPrefix(hexStr, "000000") {
			p2 = i
		}
		if p1 > -1 && p2 > -1 {
			break
		} else {
			hasher.Reset()
		}
	}
	fmt.Println("Part1:", p1)
	fmt.Println("Part2:", p2)
}
