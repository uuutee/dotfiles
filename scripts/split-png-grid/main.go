package main

import (
	"errors"
	"flag"
	"fmt"
	"image"
	"image/draw"
	"image/png"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

func usage(fs *flag.FlagSet) {
	fmt.Fprintf(fs.Output(), "Usage: %s [options] <input.png>\n", fs.Name())
	fmt.Fprintln(fs.Output(), "\nSplit a PNG image into a grid of vertical and horizontal slices.")
	fmt.Fprintln(fs.Output(), "\nOptions:")
	fs.PrintDefaults()
}

func parseArgs(argv []string) (*flag.FlagSet, string, int, int, string, string, error) {
	fs := flag.NewFlagSet("split-png-grid", flag.ContinueOnError)
	fs.SetOutput(os.Stderr)
	outDir := fs.String("output-dir", "", "directory to write slices (defaults to <input>_slices)")
	prefix := fs.String("prefix", "", "filename prefix for slices (defaults to input filename stem)")
	vertical := fs.Int("vertical", 1, "number of vertical slices (columns)")
	horizontal := fs.Int("horizontal", 1, "number of horizontal slices (rows)")
	fs.Usage = func() { usage(fs) }

	var candidateInput string
	remaining := argv
	if len(remaining) > 0 && !strings.HasPrefix(remaining[0], "-") {
		candidateInput = remaining[0]
		remaining = remaining[1:]
	}

	if err := fs.Parse(remaining); err != nil {
		if errors.Is(err, flag.ErrHelp) {
			return fs, "", 0, 0, "", "", err
		}
		return nil, "", 0, 0, "", "", err
	}

	positional := fs.Args()
	input := candidateInput
	if input != "" {
		if len(positional) > 0 {
			return fs, "", 0, 0, "", "", fmt.Errorf("unexpected extra argument: %s", positional[0])
		}
	} else {
		if len(positional) == 0 {
			return fs, "", 0, 0, "", "", fmt.Errorf("expected input path")
		}
		input = positional[0]
		if len(positional) > 1 {
			return fs, "", 0, 0, "", "", fmt.Errorf("unexpected extra argument: %s", positional[1])
		}
	}

	if *vertical < 1 {
		return fs, "", 0, 0, "", "", fmt.Errorf("vertical must be greater than 0")
	}
	if *horizontal < 1 {
		return fs, "", 0, 0, "", "", fmt.Errorf("horizontal must be greater than 0")
	}

	return fs, input, *vertical, *horizontal, *outDir, *prefix, nil
}

func ensurePNG(path string) error {
	if strings.EqualFold(filepath.Ext(path), ".png") {
		return nil
	}
	return fmt.Errorf("input file must be a .png image")
}

func deriveOutputDir(inputPath, explicit string) string {
	if explicit != "" {
		return explicit
	}
	dir := filepath.Dir(inputPath)
	base := strings.TrimSuffix(filepath.Base(inputPath), filepath.Ext(inputPath))
	return filepath.Join(dir, base+"_slices")
}

func derivePrefix(inputPath, explicit string) string {
	if explicit != "" {
		return explicit
	}
	return strings.TrimSuffix(filepath.Base(inputPath), filepath.Ext(inputPath))
}

func axisPositions(length, parts int) [][2]int {
	positions := make([][2]int, 0, parts)
	for i := 0; i < parts; i++ {
		start := length * i / parts
		end := length * (i + 1) / parts
		positions = append(positions, [2]int{start, end})
	}
	return positions
}

func splitImage(inputPath, outputDir, prefix string, vertical, horizontal int) error {
	file, err := os.Open(inputPath)
	if err != nil {
		return fmt.Errorf("open input: %w", err)
	}
	defer file.Close()

	img, err := png.Decode(file)
	if err != nil {
		return fmt.Errorf("decode png: %w", err)
	}

	if err := os.MkdirAll(outputDir, 0o755); err != nil {
		return fmt.Errorf("create output dir: %w", err)
	}

	bounds := img.Bounds()
	width := bounds.Dx()
	height := bounds.Dy()

	if width < vertical {
		return fmt.Errorf("image width %d is smaller than requested vertical slices %d", width, vertical)
	}
	if height < horizontal {
		return fmt.Errorf("image height %d is smaller than requested horizontal slices %d", height, horizontal)
	}

	xPositions := axisPositions(width, vertical)
	yPositions := axisPositions(height, horizontal)
	colDigits := len(strconv.Itoa(vertical))
	rowDigits := len(strconv.Itoa(horizontal))

	for row, yPos := range yPositions {
		top := bounds.Min.Y + yPos[0]
		bottom := bounds.Min.Y + yPos[1]
		for col, xPos := range xPositions {
			left := bounds.Min.X + xPos[0]
			right := bounds.Min.X + xPos[1]
			rect := image.Rect(0, 0, right-left, bottom-top)
			canvas := image.NewNRGBA(rect)
			draw.Draw(canvas, canvas.Bounds(), img, image.Point{X: left, Y: top}, draw.Src)

			filename := fmt.Sprintf("%s_r%0*d_c%0*d.png", prefix, rowDigits, row+1, colDigits, col+1)
			outputPath := filepath.Join(outputDir, filename)

			outFile, err := os.Create(outputPath)
			if err != nil {
				return fmt.Errorf("create slice r%d c%d: %w", row+1, col+1, err)
			}

			if err := png.Encode(outFile, canvas); err != nil {
				outFile.Close()
				return fmt.Errorf("encode slice r%d c%d: %w", row+1, col+1, err)
			}
			if err := outFile.Close(); err != nil {
				return fmt.Errorf("close slice r%d c%d: %w", row+1, col+1, err)
			}
		}
	}

	return nil
}

func run(argv []string) error {
	fs, inputPath, vertical, horizontal, outputDirFlag, prefixFlag, err := parseArgs(argv)
	if err != nil {
		if errors.Is(err, flag.ErrHelp) {
			return nil
		}
		if fs != nil {
			fs.Usage()
		}
		return err
	}

	if err := ensurePNG(inputPath); err != nil {
		return err
	}

	if _, err := os.Stat(inputPath); err != nil {
		return fmt.Errorf("stat input: %w", err)
	}

	outputDir := deriveOutputDir(inputPath, outputDirFlag)
	prefix := derivePrefix(inputPath, prefixFlag)

	return splitImage(inputPath, outputDir, prefix, vertical, horizontal)
}

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}
