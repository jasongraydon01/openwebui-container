from ollama import pull, list
from tqdm import tqdm

# List of required Ollama models
models = ["mistral:7b", "nomic-embed-text", "deepseek-r1:7b"]

def check_and_download_model(model):
    """Check if the model is installed, and if not, download it."""
    try:
        # List all available models
        response = list()
        print(response)

        # Check if the model is already installed
        model_exists = False
        for available_model in response.models:
            if available_model.model == model:
                model_exists = True
                break

        if model_exists:
            print(f"Model {model} already exists.")
        else:
            print(f"Downloading model: {model}...")
            # Pull the model if it's not installed
            current_digest, bars = '', {}
            for progress in pull(model, stream=True):
                digest = progress.get('digest', '')
                if digest != current_digest and current_digest in bars:
                    bars[current_digest].close()

                if not digest:
                    print(progress.get('status'))
                    continue

                if digest not in bars and (total := progress.get('total')):
                    bars[digest] = tqdm(total=total, desc=f'pulling {digest[7:19]}', unit='B', unit_scale=True)

                if completed := progress.get('completed'):
                    bars[digest].update(completed - bars[digest].n)

                current_digest = digest
    except Exception as e:
        print(f"Error checking or downloading {model}: {e}")
        raise  # Reraise the exception to stop the script

def main():
    """Check all required models and download if necessary."""
    for model in models:
        check_and_download_model(model)

if __name__ == "__main__":
    main()