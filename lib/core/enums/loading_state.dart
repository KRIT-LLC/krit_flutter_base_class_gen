enum LoadingState { loading, initial, error }

extension LoadingStateValues on LoadingState {

  bool get isLoading => this == LoadingState.loading;

  bool get isInitial => this == LoadingState.initial;

  bool get isError => this == LoadingState.error;
}
