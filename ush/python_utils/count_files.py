import glob

def count_files(ext,dir='.'):
    """ Function to return the number of files in the current directory
    that end with the specified file extension

    Args:
        ext: File extension string
        dir: Directory to parse (default is current directory)
    Returns:
        int: Number of files
    """

    files = glob.glob(dir + '/*.' + ext) 
    return len(files)
    
