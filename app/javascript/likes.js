document.addEventListener('turbo:load',() => {
  const pageId = 'home';
  const likeButton = document.getElementById('like-button');
  const likeCount = document.getElementById('like-count');
  if (!likeButton) return;

  fetch(`/likes/${pageId}`)
    .then(response => response.json())
    .then(data => {
      likeCount.textContent = data.likes;
    })

  likeButton.addEventListener('click', () => {
    fetch('/likes/increment', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ page_identifier:pageId })
    })
    .then(response => response.json())
    .then(data => {
      likeCount.textContent = data.likes;
    });
  });
});
