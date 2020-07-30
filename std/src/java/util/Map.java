package java.util;

public interface Map<K, V> {

	public static interface Entry<K, V> {
		K getKey();
		V getValue();
		V setValue(V value);
	}

	public boolean containsKey(Object key);
	public boolean containsValue(Object value);
	public void clear();

	public V get(Object key);
	public V put(K key, V value);
	public void putAll(Map<? extends K, ? extends V> map);
	public V remove(Object key);

	public Set<K> keySet();
	public Collection<V> values();
	public Set<Map.Entry<K,V>> entrySet();

	public int size();
	public boolean isEmpty();

}
